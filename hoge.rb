# coding: utf-8

# 【レス書き込み・スレッド作成】
# ・cgiのパスは以下の通りです。
# /bbs/write.cgi/
# 
# ・パラメータの値はエンコードしましょう。
# レス書き込み時
# DIR=[板ジャンル]&BBS=[板番号]&TIME=[投稿時間]&NAME=[名前]&MAIL=[メール]&MESSAGE=[本文]&KEY=[スレッド番号]&submit=書き込む
# 
# スレッド作成時
# DIR=[板ジャンル]&BBS=[板番号]&TIME=[投稿時間]&NAME=[名前]&MAIL=[メール]&MESSAGE=[本文]&SUBJECT=[タイトル]&submit=新規スレッド作成
#

require 'pry'
require 'net/http'
require 'uri'

def get_url(genre, bbs_id, thread_id)
 "http://jbbs.shitaraba.net/bbs/read.cgi/#{genre}/#{bbs_id}/#{thread_id}/"
end

def get
  cookie = {}

  genre = 'computer'
  bbs_id = 41596
  thread_id = 1450561934
  uri = URI.parse(get_url(genre, bbs_id, thread_id))

  Net::HTTP.start(uri.host){|http|
    response, = http.get(uri.path)

    response.get_fields('Set-Cookie').each{|str|
      k,v = str[0...str.index(';')].split('=')
      cookie[k] = v
    }
  }
  cookie
end

def post(message)
  puts "post..."
  genre = 'computer'
  bbs_id = 41596
  thread_id = 1450561934
  uri = URI.parse("http://jbbs.shitaraba.net/bbs/write.cgi/#{genre}/#{bbs_id}/#{thread_id}/")
  name = ''
  email = 'sage'
  subject = nil
  submit = unless subject
             '書き込む'
           else
             '新規スレッド作成'
           end
  cookie = get()

  form_data = {
    'DIR'     => genre.to_s,
    'BBS'     => bbs_id.to_s,
    'TIME'    => Time.now.to_i.to_s,
    'NAME'    => '', #name.to_s,
    'MAIL'    => email.to_s,
    'KEY'     => thread_id.to_s,
    'MESSAGE' => message.to_s.encode('EUC-JP', 'UTF-8'),
    'submit'  => submit.to_s.encode('EUC-JP', 'UTF-8')
  }

  req = Net::HTTP::Post.new(uri.path, {
    'Referer'    => get_url(genre, bbs_id, thread_id),
    'User-Agent' => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)",
    'Cookie'     => cookie.map{|(k,v)| "#{k}=#{v}"}.join(';')
  })
  req.set_form_data(form_data)
  Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
  puts "post finished"
end

# TODO: 30.minutes
messages = [
  "配信たのしい?",
  "将棋やらないの?",
  "トラックで暴走しないの?",
  "こんばんわ",
  "BOTからしかレス無いのかなしくない?",
  "BGMかえて",
  "Vimこわい",
  "Vimこわい",
  "Vimこわい",
  "Vimこわい",
  "Emacs",
  "Emacs",
  "Emacs",
  "NeoVim",
  "NeoVim",
  "NeoVim",
  "NeoVim"
]
loop do
  post(messages.sample)
  now = Time.now
  until (Time.now - now).to_i > (10*60)
    sleep 5*60
    puts "#{(Time.now-now).to_i / 60} min..."
  end
end
