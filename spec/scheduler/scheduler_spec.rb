require 'rspec'
require 'rails_helper'

describe Scheduler do
  # set constants used by spherical factories
  #POINT(-72.9109308480767 41.3187459427293) | POINT(-72.9038633595772 41.3121938789795) | a
  HOME1_LONGITUDE = -72.9109308480767
  HOME1_LATITUTE = 41.3187459427293
  WORK1_LONGITUDE = -72.9038633595772
  WORK1_LATITUTE = 41.3121938789795

  #POINT(-72.91102501844 41.3189297086803)   | POINT(-72.9081076060728 41.3133458958975) | a
  HOME2_LONGITUDE = -72.91102501844
  HOME2_LATITUDE = 41.3189297086803
  WORK2_LONGITUDE = -72.9081076060728
  WORK2_LATITUDE = 41.3133458958975

  HOME3_LONGITUDE = -72.917
  HOME3_LATITUDE = 41.323
  WORK3_LONGITUDE = -72.9082
  WORK3_LATITUDE = 41.3134

  HOME4_LONGITUDE = -72.917
  HOME4_LATITUDE = 41.322
  WORK4_LONGITUDE = -72.9082
  WORK4_LATITUDE = 41.3132

  let(:home1) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME1_LONGITUDE, HOME1_LATITUTE)}
  let(:work1) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK1_LONGITUDE, WORK1_LATITUTE)}
  let(:home2) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME2_LONGITUDE, HOME2_LATITUDE)}
  let(:work2) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK2_LONGITUDE, WORK2_LATITUDE)}

  let(:home3) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME3_LONGITUDE, HOME3_LATITUDE)}
  let(:work3) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK3_LONGITUDE, WORK3_LATITUDE)}

  let(:home4) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(HOME4_LONGITUDE, HOME4_LATITUDE)}
  let(:work4) {RGeo::Geographic.spherical_factory( :srid => 4326 ).point(WORK4_LONGITUDE, WORK4_LATITUDE)}

  let(:home_pickup) {DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.days}
  let(:work_pickup) {DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5+12, min: 0, sec: 0) + 1.days}

  let(:driver1) {FactoryGirl.create(:generated_driver)}
  let(:rider1) {FactoryGirl.create(:generated_rider)}
  let(:rider2) {FactoryGirl.create(:generated_rider)}
  let(:rider3) {FactoryGirl.create(:generated_rider)}

  context 'for one driver and one rider' do
    it 'schedules one-way (forward) commuter rides for same pickup times' do
			trip1 = TicketManager.request_ride(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_ride(home2, "Home2", work2, "Work2", home_pickup, false, rider1 )

      Scheduler.build_forward_fares

      expect(trip1.state).to eq('requested')
      expect(trip2.state).to eq('requested')
      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
    end
    it 'schedules commuter rides for same pickup times' do
      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup, work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home2", home_pickup, work2, "Work2", work_pickup, false, rider1 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
    end
    it 'schedules commuter rides for home pickup time apart by 15 mins' do
      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup,  work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home2", home_pickup + 15.minutes, work2, "Work2", work_pickup, false, rider1 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
    end
  end
  context 'for one driver and two riders' do
    it "schedules one-way (forward) commuter rides for riders with same work location and same pickup times" do
      trip1 = TicketManager.request_ride(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_ride(home2, "Home2", work2, "Work2", home_pickup, false, rider1 )
      trip3 = TicketManager.request_ride(home2, "Home2", work2, "Work2", home_pickup, false, rider2 )

      Scheduler.build_forward_fares

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)
			trip3 = Trip.find(trip3.id)

      expect(trip1.state).to eq('requested')
      expect(trip2.state).to eq('requested')
      expect(trip3.state).to eq('requested')

      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip3.ride_with_direction('a').fare)
    end

    it "schedules commuter rides for riders with same work location and same pickup times" do

      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup,  work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home1", home_pickup , work2, "Work2", work_pickup, false, rider1 )
      trip3 = TicketManager.request_commute(home3, "Home1", home_pickup , work2, "Work2", work_pickup, false, rider2 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)
			trip3 = Trip.find(trip3.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip3.state).to eq('fulfilled')

      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip3.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip3.ride_with_direction('b').fare)

    end

    it 'schedules commuter rides for different work locations and same pickup times' do

      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup,  work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home1", home_pickup , work2, "Work2", work_pickup, false, rider1 )
      trip3 = TicketManager.request_commute(home3, "Home1", home_pickup , work2, "Work2", work_pickup, false, rider2 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)
			trip3 = Trip.find(trip3.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip3.state).to eq('fulfilled')

      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip3.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip3.ride_with_direction('b').fare)

    end

    it "schedules commuter rides for different work locations and both riders' home pickup time apart by 15 mins" do

      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup,  work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home1", home_pickup + 15.minutes , work2, "Work2", work_pickup, false, rider1 )
      trip3 = TicketManager.request_commute(home3, "Home1", home_pickup + 15.minutes , work2, "Work2", work_pickup, false, rider2 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)
			trip3 = Trip.find(trip3.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip3.state).to eq('fulfilled')

      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip3.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip3.ride_with_direction('b').fare)


		end

    it "schedules commuter rides for different work locations and single rider's home pickup time apart by 15 mins" do

      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup + 15.minutes,  work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home1", home_pickup , work2, "Work2", work_pickup, false, rider1 )
      trip3 = TicketManager.request_commute(home3, "Home1", home_pickup + 15.minutes , work2, "Work2", work_pickup, false, rider2 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)
			trip3 = Trip.find(trip3.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip3.state).to eq('fulfilled')

      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip3.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip3.ride_with_direction('b').fare)

		end
  end



  context 'for one driver and three riders' do
    it 'schedule commuter rides for different work locations and same pickup times' do

      trip1 = TicketManager.request_commute(home1, "Home1", home_pickup , work1, "Work1", work_pickup, true, driver1.as_rider )
      trip2 = TicketManager.request_commute(home2, "Home1", home_pickup , work2, "Work2", work_pickup, false, rider1 )
      trip3 = TicketManager.request_commute(home3, "Home1", home_pickup , work3, "Work2", work_pickup, false, rider2 )
      trip4 = TicketManager.request_commute(home4, "Home1", home_pickup , work4, "Work2", work_pickup, false, rider3 )

      Scheduler.build_forward_fares
      Scheduler.build_return_fares
      Scheduler.calculate_costs

			trip1 = Trip.find(trip1.id)
			trip2 = Trip.find(trip2.id)
			trip3 = Trip.find(trip3.id)
			trip4 = Trip.find(trip4.id)

      expect(trip1.state).to eq('fulfilled')
      expect(trip2.state).to eq('fulfilled')
      expect(trip3.state).to eq('fulfilled')
      expect(trip4.state).to eq('fulfilled')

      expect(trip1.ride_with_direction('a').fare).to eq(trip2.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip3.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('a').fare).to eq(trip4.ride_with_direction('a').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip2.ride_with_direction('b').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip3.ride_with_direction('b').fare)
      expect(trip1.ride_with_direction('b').fare).to eq(trip4.ride_with_direction('b').fare)


    end
  end
end
