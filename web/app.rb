require 'sinatra'
require 'yaml'
require 'tmpdir'
require 'stringio'
require_relative '../oneswap_helper'

set :bind, '0.0.0.0'

helpers do
  def parse_options(str)
    return {} if str.nil? || str.strip.empty?
    begin
      YAML.safe_load(str) || {}
    rescue StandardError
      {}
    end
  end

  def capture_output
    out = StringIO.new
    begin
      $stdout = out
      yield
    rescue StandardError => e
      out.puts e.message
    ensure
      $stdout = STDOUT
    end
    out.string
  end
end

get '/' do
  erb :index
end

get '/convert' do
  erb :convert
end

post '/convert' do
  opts = parse_options(params[:options])
  opts[:vcenter] = params[:vcenter] unless params[:vcenter].to_s.empty?
  opts[:vuser] = params[:vuser] unless params[:vuser].to_s.empty?
  opts[:vpass] = params[:vpass] unless params[:vpass].to_s.empty?
  opts[:work_dir] ||= '/tmp'

  output = capture_output do
    OneSwapHelper.new.convert(params[:name], opts)
  end

  erb :result, locals: { output: output }
end

get '/import' do
  erb :import
end

post '/import' do
  opts = parse_options(params[:options])
  if params[:file] && (tmp = params[:file][:tempfile])
    filename = params[:file][:filename]
    path = File.join(Dir.tmpdir, "#{Time.now.to_i}_#{filename}")
    File.open(path, 'wb') { |f| f.write(tmp.read) }
    if filename.downcase.end_with?('.vmdk')
      opts[:vmdk] = path
    else
      opts[:ova] = path
    end
  end
  opts[:work_dir] ||= '/tmp'

  output = capture_output do
    OneSwapHelper.new.import(opts)
  end

  erb :result, locals: { output: output }
end

__END__

@@layout
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>OneSwap Web</title>
</head>
<body>
<h1>OneSwap Web Interface</h1>
<nav>
  <a href="/convert">Convert</a> |
  <a href="/import">Import</a>
</nav>
<hr>
<%= yield %>
</body>
</html>

@@index
<p>Select an action:</p>
<ul>
  <li><a href="/convert">Convert VM</a></li>
  <li><a href="/import">Import Image/OVA</a></li>
</ul>

@@convert
<form action="/convert" method="post">
  <label>VM Name/ID: <input type="text" name="name" required></label><br>
  <label>vCenter Host: <input type="text" name="vcenter"></label><br>
  <label>User: <input type="text" name="vuser"></label><br>
  <label>Password: <input type="password" name="vpass"></label><br>
  <label>Additional Options (YAML):<br>
    <textarea name="options" rows="8" cols="60"></textarea>
  </label><br>
  <input type="submit" value="Convert">
</form>

@@import
<form action="/import" method="post" enctype="multipart/form-data">
  <label>OVA/VMDK File: <input type="file" name="file"></label><br>
  <label>Additional Options (YAML):<br>
    <textarea name="options" rows="8" cols="60"></textarea>
  </label><br>
  <input type="submit" value="Import">
</form>

@@result
<pre><%= output %></pre>
