require File.dirname(__FILE__) + '/spec_helper.rb'

require 'flay'

class ShouldDuplicate
  def initialize(threshold)
    @threshold = threshold
    @flay = Flay.new({:fuzzy => false, :verbose => false, :mass => @threshold})
  end
  def matches?(actual)
    @flay.process(*Flay.expand_dirs_to_files(actual))
    @flay.total > 0
  end
  def failure_message_for_should
    "Expected source to contain duplication, but it didn't"
  end
  def failure_message_for_should_not
    "Expected source not to contain duplication, but got:\n#{report}"
  end
  def report
    lines = ["Total mass = #{@flay.total} (threshold = #{@threshold})"]
    @flay.masses.each do |hash, mass|
      nodes = @flay.hashes[hash]
      match = @flay.identical[hash] ? "IDENTICAL" : "Similar"
      lines << ("%s code found in %p (%d)" % [match, nodes.first.first, mass])
      nodes.each { |x| lines << "  #{x.file}:#{x.line}" }
    end
    lines.join("\n")
  end
end

class ShouldSimian
  def initialize(threshold)
    @threshold = threshold
  end
  def matches?(actual)
    files = Flay.expand_dirs_to_files(actual).join(' ')
    simian_jar = Dir["#{ENV['SIMIAN_HOME']}/simian*.jar"].first
    @simian = `java -jar #{simian_jar} -threshold=#{@threshold} #{files}`
    !@simian.include?("Found 0 duplicate lines")
  end
  def failure_message_for_should
    "Expected source to contain textual duplication, but it didn't"
  end
  def failure_message_for_should_not
    "Expected source not to contain textual duplication, but got:\n#{@simian}"
  end
end

def flay(threshold)
  ShouldDuplicate.new(threshold)
end

def simian(threshold)
  ShouldSimian.new(threshold)
end

describe 'Reek source code' do
  it 'has no smells' do
    Dir['lib/**/*.rb'].should_not reek
  end
  it 'has no structural duplication' do
    ['lib'].should_not flay(16)
  end
  it 'has no textual duplication' do
    ['lib'].should_not simian(3)
  end
  it 'has no structural duplication in the tests' do
    ['spec/reek'].should_not flay(25)
  end
  it 'has no textual duplication in the tests' do
    ['spec/reek'].should_not simian(8)
  end
end
