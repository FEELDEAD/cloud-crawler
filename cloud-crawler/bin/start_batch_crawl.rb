#!/usr/bin/env ruby
#
# Copyright (c) 2013 Charles H Martin, PhD
#  
#  Calculated Content (TN)
#  http://calculatedcontent.com
#  charles@calculatedcontent.com
#
# All rights reserved.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL MADE BY MADE LTD BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'rubygems'
require 'bundler/setup'
require 'cloud-crawler'
require 'trollop'

#TODO:  Implement .cloud_crawler/config.yml  file also with these settings

opts = Trollop::options do
  opt :urls, "urls to crawl", :short => "-u", :multi => true,  :default => "http://www.livestrong.com"
  opt :job_name, "name of crawl", :short => "-n",  :default => "LS"

  opt :flush,  "flush pages out of local redis cache after every batch crawl", :short => "-x", :default => true
  opt :batch_size, "maximum slice for batch job", :short => "-b", :default => 1000
  
  opt :s3_bucket, "save intermediate results to s3 bucket",  :short => "-s", :default => "crawls"
  opt :keep_tmp_files, "save intermediate files to local dir", :short => "-t",  :type => :string, :default => false

 
  opt :delay, "delay between requests (not used yet, see worker interval)",  :short => "-d", :default => 0  # not used yet
  opt :depth_limit, "limit the depth of the crawl", :short => "-l", :type => :int, :default => nil
  opt :obey_robots_txt, "obey the robots exclusion protocol", :short => "-o", :default => true
  opt :verbose, "verbose logging (not availabe yet)", :short => "-v", :default => false
  opt :user_agent, "identify self as CloudCrawler/VERSION", :short => "-A", :default => "CloudCrawler"
  opt :redirect_limit, "number of times HTTP redirects to be followed", :short => "-R", :default => 5
  opt :accept_cookies, "accept cookies from the server and send them back?", :short => "-C",  :default => false
  opt :read_timeout, "HTTP read timeout in seconds",  :short => "-T", :type => :int, :default => nil
  opt :skip_query_strings, "skip any link with a query string? e.g. http://foo.com/?u=user ",  :short => "-Q", :default => false
  opt :discard_page_bodies, "throw away the page response body after scanning it for links",  :short => "-d", :default => true

  opt :proxy_host, "proxy server hostname", :type => :string, :default => nil
  opt :proxy_port, " proxy server port number",  :type => :int, :default => nil
  
  opt :outside_domain, "allow links outside of the root domain", :short => "-X", :default => false
  opt :inside_domain, "allow links inside of the root domain", :short => "-Y", :default => true

  opt :qless_db, "", :short => "-B", :default => 0   # not used yet
end

Trollop::die :urls, "can not be empty" if opts[:url].empty?
Trollop::die :name, "crawl name necessary" if opts[:name].empty?

Trollop::die :max_slice, "can not be <= 0" if opts[:max_slice] <= 0
Trollop::die :s3_bucket, "s3 bucket #{opts[:s3_bucket]} not found, please make first" if `s3cmd ls | grep "#{opts[:s3_bucket]}"`.empty?

urls = opts[:urls].map { |u| URI::encode(u)  }
CloudCrawler::batch_crawl(urls, opts)
