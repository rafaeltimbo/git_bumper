require 'spec_helper'

RSpec.describe GitBumper::CLI do
  let(:options) do
    {
      klass: GitBumper::Tag,
      prefix: 'v',
      increment: :patch
    }
  end

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        `git init test`

        Dir.chdir('test') do
          `git config user.email "test@example.com"`
          `git config user.name "test user"`
          `touch a.txt`
          `git add a.txt`
          `git commit -m foo`

          example.run
        end
      end
    end
  end

  before do
    allow(STDIN).to receive(:gets) { 'yes' } # assume yes for every prompt
  end

  describe 'no tag present' do
    it 'exists with an error' do
      subject = described_class.new(options)

      expect do
        begin
          subject.run
        rescue SystemExit
        end
      end.to output(/No tags found/).to_stderr
    end
  end

  context 'there is a tag present' do
    before do
      `git tag v0.1.0`
    end

    it 'creates a greater tag' do
      subject = described_class.new(options)
      subject.run

      expect(`git tag`.split).to eql(%w(v0.1.0 v0.1.1))
    end
  end

  context 'build tags' do
    before do
      `git tag v1`
    end

    it 'creates a greater tag' do
      subject = described_class.new(options.merge(klass: GitBumper::BuildTag))
      subject.run

      expect(`git tag`.split).to eql(%w(v1 v2))
    end
  end

  context 'custom prefix' do
    before do
      `git tag a1.0.0`
    end

    it 'creates a greater tag' do
      subject = described_class.new(options.merge(prefix: 'a'))
      subject.run

      expect(`git tag`.split).to eql(%w(a1.0.0 a1.0.1))
    end
  end

  context 'increments major' do
    before do
      `git tag v1.0.0`
    end

    it 'creates a greater tag' do
      subject = described_class.new(options.merge(increment: :major))
      subject.run

      expect(`git tag`.split).to eql(%w(v1.0.0 v2.0.0))
    end
  end

  context 'increments minor' do
    before do
      `git tag v1.0.0`
    end

    it 'creates a greater tag' do
      subject = described_class.new(options.merge(increment: :minor))
      subject.run

      expect(`git tag`.split).to eql(%w(v1.0.0 v1.1.0))
    end
  end
end
