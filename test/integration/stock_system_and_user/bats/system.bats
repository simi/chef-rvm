#!/usr/bin/env bats

default_ruby="ruby-1.9.3-p484"
https_url="https://google.com"

setup() {
  source /etc/profile.d/rvm.sh
}

@test "creates system install RVM directory" {
  [ -d "/usr/local/rvm" ]
}

@test "sources into environment" {
  [ "$(type rvm | head -1)" = "rvm is a function" ]
}

@test "installs $default_ruby" {
  run sudo -u wigglebottom -i rvm list strings
  [ "$status" -eq 0 ]
  [ "$output" = "$default_ruby" ]
}

@test "sets $default_ruby as the default" {
  run sudo -u wigglebottom -i rvm list default string
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$default_ruby" ]
}

@test "default Ruby can use openssl from stdlib" {
  expr="puts OpenSSL::PKey::RSA.new(32).to_pem"
  run sudo -u wigglebottom -i rvm $default_ruby do ruby -ropenssl -e "$expr"
  [ "$status" -eq 0 ]
}

@test "default Ruby can install nokogiri gem" {
  run sudo -u wigglebottom -i rvm $default_ruby do gem install nokogiri --no-ri --no-rdoc
  [ "$status" -eq 0 ]
}

@test "default Ruby can use nokogiri with openssl" {
  expr="puts Nokogiri::HTML(open('$https_url')).css('input')"
  run sudo -u wigglebottom -i rvm $default_ruby do ruby -ropen-uri -rnokogiri -e "$expr"
  [ "$status" -eq 0 ]
}
