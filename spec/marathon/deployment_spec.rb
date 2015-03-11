require 'spec_helper'

DEPLOYMENT_EXAMPLE = {
  :affectedApps => ["/test"],
  :id => "867ed450-f6a8-4d33-9b0e-e11c5513990b",
  :steps => [
      [
          {
              :action => "ScaleApplication",
              :app => "/test"
          }
      ]
  ],
  :currentActions => [
    {
      :action => "ScaleApplication",
      :app => "/test"
    }
  ],
  :version => "2014-08-26T08:18:03.595Z",
  :currentStep => 1,
  :totalSteps => 1
}

describe Marathon::Deployment do

  describe '#to_s' do
    subject { described_class.new(DEPLOYMENT_EXAMPLE) }

    let(:expected_string) do
      'Marathon::Deployment { ' \
        + ':id => 867ed450-f6a8-4d33-9b0e-e11c5513990b :affectedApps => ["/test"] :currentStep => 1 :totalSteps => 1 }'
    end

    its(:to_s) { should == expected_string }
  end

  describe '#to_json' do
    subject { described_class.new(DEPLOYMENT_EXAMPLE) }

    its(:to_json) { should == DEPLOYMENT_EXAMPLE.to_json }
  end

  describe 'attributes' do
    subject { described_class.new(DEPLOYMENT_EXAMPLE) }

    its(:id) { should == DEPLOYMENT_EXAMPLE[:id] }
    its(:affectedApps) { should == DEPLOYMENT_EXAMPLE[:affectedApps] }
    its(:version) { should == DEPLOYMENT_EXAMPLE[:version] }
    its(:currentStep) { should == DEPLOYMENT_EXAMPLE[:currentStep] }
    its(:totalSteps) { should == DEPLOYMENT_EXAMPLE[:totalSteps] }
  end

  describe '#delete' do
    subject { described_class.new(DEPLOYMENT_EXAMPLE) }

    it 'deletes the deployment' do
      expect(described_class).to receive(:delete).with(DEPLOYMENT_EXAMPLE[:id], false)
      subject.delete
    end

    it 'force deletes the deployment' do
      expect(described_class).to receive(:delete).with(DEPLOYMENT_EXAMPLE[:id], true)
      subject.delete(true)
    end
  end

  describe '.list' do
    subject { described_class }

    it 'lists deployments', :vcr do
      # start a deployment
      Marathon::App.change('/test', {:instances => 0})
      sleep 1
      Marathon::App.change('/test', {:instances => 2})
      sleep 1

      deployments = subject.list
      expect(deployments).to be_instance_of(Array)
      expect(deployments.first).to be_instance_of(Marathon::Deployment)
    end
  end

  describe '.delete' do
    subject { described_class }

    it 'deletes deployments', :vcr do
      # start a deployment
      info = Marathon::App.change('/test', {:instances => 1})
      expect(subject.delete(info.deploymentId)).to be_instance_of(Marathon::DeploymentInfo)
    end
  end

end
