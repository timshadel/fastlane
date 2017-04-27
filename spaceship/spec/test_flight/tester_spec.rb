require 'spec_helper'

describe Spaceship::TestFlight::Tester do
  let(:tester) { Spaceship::TestFlight::Tester.new }
  let(:mock_client) { double('MockClient') }

  before do
    Spaceship::TestFlight::Base.client = mock_client
  end

  context 'attr_mapping' do
    let(:tester) do
      Spaceship::TestFlight::Tester.new({
        'id' => 1,
        'email' => 'email@domain.com'
      })
    end

    it 'has them' do
      expect(tester.tester_id).to eq(1)
      expect(tester.email).to eq('email@domain.com')
    end
  end

  context 'collections' do
    before do
      mock_client_response(:testers_for_app, with: { app_id: 'app-id' }) do
        [
          {
            id: 1,
            email: "email_1@domain.com"
          },
          {
            id: 2,
            email: 'email_2@domain.com'
          }
        ]
      end
    end

    context '.all' do
      it 'returns all of the testers' do
        groups = Spaceship::TestFlight::Tester.all(app_id: 'app-id')
        expect(groups.size).to eq(2)
        expect(groups.first).to be_instance_of(Spaceship::TestFlight::Tester)
      end
    end

    context '.find' do
      it 'returns a Tester by email address' do
        tester = Spaceship::TestFlight::Tester.find(app_id: 'app-id', email: 'email_1@domain.com')
        expect(tester).to be_instance_of(Spaceship::TestFlight::Tester)
        expect(tester.tester_id).to be(1)
      end

      it 'returns nil if no Tester matches' do
        tester = Spaceship::TestFlight::Tester.find(app_id: 'app-id', email: 'NaN@domain.com')
        expect(tester).to be_nil
      end
    end
  end

  context 'instances' do
    let(:tester) { Spaceship::TestFlight::Tester.new('id' => 2, 'email' => 'email@domain.com') }

    context '.remove_from_app!' do
      it 'removes a tester from the app' do
        expect(mock_client).to receive(:delete_tester_from_app).with(app_id: 'app-id', tester_id: 2)
        tester.remove_from_app!(app_id: 'app-id')
      end
    end
  end
end
