require 'mechanize'
require 'logger'
require 'cgi'

class Bugzilla

  # If set then no new bugs will be posted
  attr_accessor :dummy

  # A module used to represent the state of different bugs
  module Bug
    CLOSED = 0
    OPEN = 1
    RESOLVED = 2
    VERIFIED = 3
    NEW = 4
    FIXED = 5
    WONTFIX = 6
    INVALID = 7
    REOPENED = 8
  end

  # Instantiate a new Bugzilla object
  # * url - The URL pointing to the Bugzilla server
  # * username - Your Bugzilla username
  # * password - Your Bugzilla password
  # * ba_username - The HTTP basic authentication username, if any.
  # * ba_password - The HTTP basic authentication password, if any.
  def initialize(url, username, password, ba_username = nil, ba_password = nil)
    @agent = WWW::Mechanize.new
    if ba_username != nil
      @agent.auth(ba_username, ba_password)
    end
    @url = url
    @username = username
    @password = password
    @log = Logger.new(STDOUT)
    @log.progname = self.class.to_s
    @log.level = Logger::DEBUG
    @dummy =false
  end

  # Log in to the Bugzilla server
  def authenticate
    action = "#{@url}index.cgi"
    page = @agent.get(@url)
    form = page.form_with(:action => action)
    if form != nil
      @log.debug "Authenticating with #{@url}"
      form['Bugzilla_login']=@username
      form['Bugzilla_password']=@password
      page = @agent.submit form
      if page.search(".//td[@id='error_msg']").empty?
        @log.debug "Authenticated successfully"
        return true
      else
        @log.error page.search(".//td[@id='error_msg']")[0].content.strip
      end
    else
      @log.error "Unable to find #{action} form"
    end
    return false
  end

  # Count the number of bugs with a particular product and component
  def count(summary='', product="", component="")
    url = "#{@url}/buglist.cgi?product=#{product}&component=#{component}&short_desc=#{CGI.escape(summary)}&short_desc_type=allwordssubstr"
    @log.debug url
    page = @agent.get(url)
    if page.search(".//td[@id='error_msg']").empty?
      @log.debug "Authenticated successfully"
      @log.debug page.search("//span[@class='bz_result_count']")[0].content
      count = page.search("//table[@class='bz_buglist']/tr").length
      count -= 1 if count > 0
      return count
    else
      @log.error page.search(".//td[@id='error_msg']")[0].content.strip
    end
    return 0
  end

  # List the bugs assigned to a particular user
  def assigned_to(assignee)
    url = "#{@url}buglist.cgi?emailassigned_to1=1&emailtype1=exact&email1=#{assignee}&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED"
    @log.debug url
    page = @agent.get(url)
    bugs = []
    if page.search(".//td[@id='error_msg']").empty?
      headers = page.search(".//tr[contains(@class,'bz_buglist_header')][1]/th")
      columns = []
      index = 0
      headers.each {|header|
        columns << header.content.strip.downcase
      }
      page.search(".//tr[contains(@class,'bz_bugitem')]").each { |row|
        bug = {}
        child_count = 0
        row.children.each { |child|
          if child.element?
            
            if columns[child_count] == 'id'
              bug[columns[child_count]] = child.content.strip.match(/([0-9]+).*/)[1].to_i
            elsif columns[child_count] == 'pri'
              bug[columns[child_count]] = child.content.strip.match(/P([0-9]+).*/)[1].to_i
            elsif columns[child_count] == 'status'
              status = child.content.strip
              if status =~ /CLOS/
                bug[columns[child_count]] = Bug::CLOSED
              elsif status =~ /OPEN/
                bug[columns[child_count]] = Bug::OPEN
              elsif status =~ /RES/
                bug[columns[child_count]] = Bug::RESOLVED
              elsif status =~ /VERI/
                bug[columns[child_count]] = Bug::VERIFIED
              elsif status =~ /NEW/
                bug[columns[child_count]] = Bug::NEW
              elsif status =~ /REOP/
                bug[columns[child_count]] = Bug::REOPENED
              else
                @log.debug "I don't understand #{status}"
              end
            elsif columns[child_count] == 'resolution'
              resolution = child.content.strip
              if resolution =~ /FIX/
                bug[columns[child_count]] = Bug::FIXED
              elsif resolution =~ /WONT/
                bug[columns[child_count]] = Bug::WONTFIX
              elsif resolution =~ /INV/ 
                bug[columns[child_count]] = Bug::INVALID
              else
                bug[columns[child_count]] = resolution
              end
            else
              bug[columns[child_count]] = child.content.strip
            end
            child_count = child_count + 1
          end
        }
        bugs << bug
      }
    else
      @log.error page.search(".//td[@id='error_msg']")[0].content.strip
    end
    return bugs
  end

  # Post a new bug to Bugzilla
  def post(summary, description, assignee, product="TestProduct", component="")
    @log.debug "Attempting to file a new bug"
    url = "#{@url}/enter_bug.cgi?product=#{product}&assigned_to=#{assignee}&component=#{component}"
    @log.debug url
    page = @agent.get(url)
    form_name = 'Create'
    form = page.form_with(:name => form_name)
    if form
      form['short_desc']=summary
      form['comment']=description
      form['assignee']=assignee
      form['component']=component if not component.empty?
      page = @agent.submit form if not @dummy
      @log.info page.search(".//td[@id='title']")[0].content.strip
      # Read the bug number from the page
      return page.search(".//a[@title='NEW - #{summary}']")[0].content.match(/Bug ([0-9]+)/)[1] 
    else
      @log.error "Unable to find form with name #{form_name}"
    end
  end
end
