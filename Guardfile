# frozen_string_literal: true

guard(
  'rspec',
  all_on_start: true,
  all_after_pass: true,
  cmd: 'bundle exec rspec'
) do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})       { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')    { 'spec' }
  watch(%r{^spec/.+_shared\.rb$}) { 'spec' }
end

guard(
  'rubocop',
  all_on_start: true,
  all_after_pass: true,
  notification: true,
  cmd: 'bundle exec rubocop'
) do
  watch(%r{^lib/(.+)\.rb$})
  watch(%r{^spec/.+_spec\.rb$})
  watch('.rubocop.yml')
end
