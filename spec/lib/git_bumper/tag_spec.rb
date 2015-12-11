require 'spec_helper'

RSpec.describe GitBumper::Tag do
  describe '.parse' do
    subject { described_class }

    context 'passing an invalid tag' do
      it 'returns false' do
        %w(abcd v0 1234 0.0.0 v0.0).each do |invalid_tag|
          expect(subject.parse(invalid_tag)).to be false
        end
      end
    end

    context 'passing a valid tag' do
      it 'returns a tag object' do
        %w(v0.0.1 v0.10.1 v10.0.0 v11.11.11).each do |valid_tag|
          tag = subject.parse(valid_tag)

          expect(tag).to be_kind_of(GitBumper::Tag)
          expect(tag.to_s).to eql(valid_tag)
        end
      end

      it 'converts version numbers to integer' do
        tag = subject.parse('v0.0.1')

        expect(tag.major).to be 0
        expect(tag.minor).to be 0
        expect(tag.patch).to be 1
      end
    end
  end

  subject { described_class.new('v', 0, 0, 0) }

  it { is_expected.to respond_to(:prefix) }
  it { is_expected.to respond_to(:major) }
  it { is_expected.to respond_to(:major=) }
  it { is_expected.to respond_to(:minor) }
  it { is_expected.to respond_to(:minor=) }
  it { is_expected.to respond_to(:patch) }
  it { is_expected.to respond_to(:patch=) }
end
