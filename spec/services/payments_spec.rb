require 'rspec'

describe CommuterPass do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  context 'payouts' do
    it 'gets processed' do

      driver = FactoryGirl.create(:generated_driver)
      initial = driver.commuter_balance_cents

      recipient = Stripe::Recipient.create(
        :name => driver.full_name,
        :type => 'individual',
        :email => driver.email,
        :card => stripe_helper.generate_card_token(:funding => 'debit')
      )
      driver.stripe_recipient_id = recipient.id
      driver.save

      CommuterPass.process_payout driver, 1000
      driver = Driver.find(driver.id)
      final = driver.commuter_balance_cents
      expect(final).to eq(initial - 1000)
    end
  end
end
