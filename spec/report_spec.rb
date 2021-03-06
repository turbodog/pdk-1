require 'spec_helper'
require 'tmpdir'

describe PDK::Report do
  def tmpdir
    @tmpdir ||= Dir.mktmpdir
  end

  after(:each) do
    FileUtils.remove_entry_secure(@tmpdir) if @tmpdir
  end

  it 'should include formats junit and text' do
    expect(PDK::Report.formats).to eq(%w(junit text))
  end

  it 'should have a default format of junit' do
    expect(PDK::Report.default_format).to eq('text')
  end

  context 'when no format is specified' do
    let(:report) { PDK::Report.new(File.join(tmpdir, 'report.txt')) }

    it 'should instantiate its format to text' do
      expect(report).to receive(:prepare_text).with('cmd output')
      report.write('cmd output')
    end
  end

  context 'when a format is specified' do
    let(:report) { PDK::Report.new(File.join(tmpdir, 'report.xml'), 'junit') }

    it 'should instantiate its format to junit' do
      expect(report).to receive(:prepare_junit).with('cmd output')
      report.write('cmd output')
    end
  end
end
