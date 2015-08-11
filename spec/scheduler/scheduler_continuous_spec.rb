require 'rspec'

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

	# Far Away
  HOME4_LONGITUDE = -72.917
  HOME4_LATITUDE = 43.322
  WORK4_LONGITUDE = -72.9082
  WORK4_LATITUDE = 43.3132

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

	context 'cutoff' do
		it 'should mark rides for tomorrow that are past their scheduling window as unfulfilled' do
			
			h_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.day
			w_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5+12, min: 0, sec: 0) + 1.day
			trip = TripController.request_commute(home1, 'Home1', h_pickup,  work1, 'Work1', w_pickup, true, driver1.as_rider)

			now = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 11+12, min: 35, sec: 0)
			SchedulerContinuous.cutoff now 

			trip.reload
      expect(trip.state).to eq('unfulfilled')
			trip.rides.each do |ride|
				expect(ride.state).to eq('commute_scheduler_failed')
			end
		end

		it 'should not mark rides for tomorrow that are not their scheduling window as unfulfilled' do
			
			h_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7, min: 0, sec: 0) + 1.day
			w_pickup = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 5+12, min: 0, sec: 0) + 1.day
				
			trip = TripController.request_commute(home1, 'Home1', h_pickup,  work1, 'Work1', w_pickup, true, driver1.as_rider)
			Rails.logger.debug trip.start_time.in_time_zone

			now = DateTime.now.in_time_zone("Pacific Time (US & Canada)").change(hour: 7+12, min: 35, sec: 0)
			SchedulerContinuous.cutoff now 

			trip.reload
      expect(trip.state).to eq('requested')
			trip.rides.each do |ride|
				expect(ride.state).to eq('requested')
			end
		end
	end

	context 'prepare' do
		it 'should copy unfulfilled ride requests for tomorrow into temp tables' do
			trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)

			SchedulerContinuous.prepare

			expect{ TempRide.find(trip.rides[0].id) }.not_to raise_exception(ActiveRecord::RecordNotFound)
			expect{ TempRide.find(trip.rides[1].id) }.not_to raise_exception(ActiveRecord::RecordNotFound)

		end

		it 'should not copy fulfilled ride requests for tomorrow into temp tables' do
			trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)
			trip.rides[0].scheduled!
			trip.rides[1].scheduled!
			trip.fulfilled!

			SchedulerContinuous.prepare

			expect{ TempRide.find(trip.rides[0].id) }.to raise_exception(ActiveRecord::RecordNotFound)
			expect{ TempRide.find(trip.rides[1].id) }.to raise_exception(ActiveRecord::RecordNotFound)

		end

		it 'should scheduled fares for tomorrow into temp tables' do
			trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)
			trip.rides[0].scheduled!
			trip.rides[1].scheduled!
			trip.fulfilled!

			SchedulerContinuous.prepare

			expect{ TempFare.find(trip.rides[0].fare.id) }.not_to raise_exception(ActiveRecord::RecordNotFound)
			expect{ TempFare.find(trip.rides[1].fare.id) }.not_to raise_exception(ActiveRecord::RecordNotFound)

		end


		it 'should not copy cancelled fares for tomorrow into temp tables' do
			trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)
			trip.rides[0].scheduled!
			trip.rides[1].scheduled!
			trip.fulfilled!
			trip.rides[0].fare = Fare.new
			trip.rides[0].fare.schedule!
			trip.rides[0].save
			trip.rides[1].fare = Fare.new
			trip.rides[1].fare.schedule!
			trip.rides[1].save
			trip.rides[0].reload
			trip.rides[1].reload
			trip.rides[0].cancel_ride
			trip.rides[1].cancel_ride

			SchedulerContinuous.prepare

			expect{ TempFare.find(trip.rides[0].fare.id) }.to raise_exception(ActiveRecord::RecordNotFound)
			expect{ TempFare.find(trip.rides[1].fare.id) }.to raise_exception(ActiveRecord::RecordNotFound)

		end
	end

  context 'for one driver and one rider' do
    it 'schedules commuter rides for same pickup times' do
			rider_trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, false, rider1)
			driver_trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers

			rider_ride = TempRide.find(rider_trip.rides[0].id)
			driver_ride = TempRide.find(driver_trip.rides[0].id)
      expect(rider_ride.state).to eq('provisional')
      expect(driver_ride.state).to eq('provisional')
      expect(rider_ride.temp_fare).to eq(driver_ride.temp_fare)
    end

		it 'does not schedule commuter rides for same pickup times when not in same location' do
			rider_trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, false, rider1)
			driver_trip = TripController.request_commute(home4, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers

			rider_ride = TempRide.find(rider_trip.rides[0].id)
			driver_ride = TempRide.find(driver_trip.rides[0].id)
      expect(rider_ride.state).to eq('requested')
      expect(driver_ride.state).to eq('requested')
      expect(rider_ride.temp_fare).to eq(nil)
      expect(driver_ride.temp_fare).to eq(nil)
    end
		
    it 'schedules commuter rides for home pickup time apart by 15 mins' do
			rider_trip = TripController.request_commute(home1, 'Home1', home_pickup + 15.minutes,  work1, 'Work1', work_pickup, false, rider1)
			driver_trip = TripController.request_commute(home1, 'Home1', home_pickup,  work1, 'Work1', work_pickup, true, driver1.as_rider)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers

			rider_ride = TempRide.find(rider_trip.rides[0].id)
			driver_ride = TempRide.find(driver_trip.rides[0].id)
      expect(rider_ride.state).to eq('provisional')
      expect(driver_ride.state).to eq('provisional')
			expect(rider_ride.temp_fare).not_to eq(nil)
      expect(rider_ride.temp_fare).to eq(driver_ride.temp_fare)
    end

  end

  context 'for one driver and two riders' do
    it "schedules commuter rides for riders with same work location and same pickup times" do

			r1trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			r2trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			dtrip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, true, rider1)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers
			SchedulerContinuous.fill_open_fares

			r1ride = TempRide.find(r1trip.rides[0].id)
			r2ride = TempRide.find(r2trip.rides[0].id)
			dride = TempRide.find(dtrip.rides[0].id)
      expect(r1ride.state).to eq('provisional')
      expect(r2ride.state).to eq('provisional')
      expect(dride.state).to eq('provisional')

      expect(r1ride.temp_fare).to eq(dride.temp_fare)
      expect(r2ride.temp_fare).to eq(dride.temp_fare)

			r1ride = TempRide.find(r1trip.rides[1].id)
			r2ride = TempRide.find(r2trip.rides[1].id)
			dride = TempRide.find(dtrip.rides[1].id)
      expect(r1ride.state).to eq('provisional')
      expect(r2ride.state).to eq('provisional')
      expect(dride.state).to eq('provisional')

      expect(r1ride.temp_fare).to eq(dride.temp_fare)
      expect(r2ride.temp_fare).to eq(dride.temp_fare)

    end

    it "schedules commuter rides for the rider that is close enough with same work location and same pickup times" do

			r1trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			r2trip = TripController.request_commute(home3, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			dtrip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, true, rider1)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers
			SchedulerContinuous.fill_open_fares

			r1ride = TempRide.find(r1trip.rides[0].id)
			r2ride = TempRide.find(r2trip.rides[0].id)
			dride = TempRide.find(dtrip.rides[0].id)
      expect(r1ride.state).to eq('provisional')
      expect(r2ride.state).to eq('requested')
      expect(dride.state).to eq('provisional')

      expect(r1ride.temp_fare).to eq(dride.temp_fare)
      expect(r2ride.temp_fare).to eq(nil)

    end

		it 'schedules and then removes unsucessful ride' do
			r1trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			r2trip = TripController.request_commute(home4, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			dtrip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, true, rider1)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers
			SchedulerContinuous.fill_open_fares
			SchedulerContinuous.remove_unsuccessful_rides

			expect { TempRide.find(r2trip.rides[0].id) }.to raise_exception(ActiveRecord::RecordNotFound)
			expect { TempRide.find(r2trip.rides[1].id) }.to raise_exception(ActiveRecord::RecordNotFound)

		end

    it "publishes scheduling results to live database" do

			r1trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			r2trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider2)
			dtrip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, true, driver1.as_rider)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers
			SchedulerContinuous.fill_open_fares
			SchedulerContinuous.remove_unsuccessful_rides
			SchedulerContinuous.publish

			r1ride = Ride.find(r1trip.rides[0].id)
			r2ride = Ride.find(r2trip.rides[0].id)
			Rails.logger.debug r1ride
			Rails.logger.debug r2ride
			Rails.logger.debug 'h'
			dride = Ride.find(dtrip.rides[0].id)
      expect(r1ride.state).to eq('scheduled')
      expect(r2ride.state).to eq('scheduled')
      expect(dride.state).to eq('scheduled')

      expect(r1ride.fare).to eq(dride.fare)
      expect(r2ride.fare).to eq(dride.fare)

			r1ride = Ride.find(r1trip.rides[1].id)
			r2ride = Ride.find(r2trip.rides[1].id)
			dride = Ride.find(dtrip.rides[1].id)
      expect(r1ride.state).to eq('scheduled')
      expect(r2ride.state).to eq('scheduled')
      expect(dride.state).to eq('scheduled')

      expect(r1ride.fare).to eq(dride.fare)
      expect(r2ride.fare).to eq(dride.fare)

    end


    it "schedules commuter rides for riders with same work location and same pickup times on subsequent runs" do

			r1trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider1)
			dtrip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, true, driver1.as_rider)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers
			SchedulerContinuous.fill_open_fares
			SchedulerContinuous.remove_unsuccessful_rides
			SchedulerContinuous.publish

			r2trip = TripController.request_commute(home1, 'Home1', home_pickup ,  work1, 'Work1', work_pickup, false, rider2)

      SchedulerContinuous.prepare
			SchedulerContinuous.assign_rides_to_unscheduled_drivers
			SchedulerContinuous.fill_open_fares
			SchedulerContinuous.remove_unsuccessful_rides
			SchedulerContinuous.publish

			r1ride = Ride.find(r1trip.rides[0].id)
			r2ride = Ride.find(r2trip.rides[0].id)
			dride = Ride.find(dtrip.rides[0].id)
      expect(r1ride.state).to eq('scheduled')
      expect(r2ride.state).to eq('scheduled')
      expect(dride.state).to eq('scheduled')

      expect(r1ride.fare).to eq(dride.fare)
      expect(r2ride.fare).to eq(dride.fare)

    end


  end



  context 'for one driver and three riders' do
    it 'schedule commuter rides for different work locations and same pickup times' do
      aside1 = TripController.request_commute_leg(home1, "Home1", work1, "Work1", home_pickup, true, driver1.as_rider, 0 )
      bside1 = TripController.request_commute_leg(work1, "Work1", home1, "Home1", work_pickup, true, driver1.as_rider, aside1.trip_id)

      aside2 = TripController.request_commute_leg(home2, "Home2", work2, "Work2", home_pickup, true, rider1, 0 )
      bside2 = TripController.request_commute_leg(work2, "Work2", home2, "Home2", work_pickup, true, rider1, aside2.trip_id)

      aside3 = TripController.request_commute_leg(home3, "Home3", work3, "Work3", home_pickup, true, rider2, 0 )
      bside3 = TripController.request_commute_leg(work3, "Work3", home3, "Home3", work_pickup, true, rider2, aside3.trip_id)

      aside4 = TripController.request_commute_leg(home4, "Home4", work4, "Work4", home_pickup, true, rider3, 0 )
      bside4 = TripController.request_commute_leg(work4, "Work4", home4, "Home4", work_pickup, true, rider3, aside4.trip_id)

      SchedulerContinuous.build_forward_fares
      SchedulerContinuous.build_return_fares
      SchedulerContinuous.calculate_costs

      expect(aside1.trip.state).to eq('fulfilled')
      expect(bside1.trip.state).to eq('fulfilled')
      expect(aside2.trip.state).to eq('fulfilled')
      expect(bside2.trip.state).to eq('fulfilled')
      expect(aside3.trip.state).to eq('fulfilled')
      expect(bside3.trip.state).to eq('fulfilled')
      expect(aside4.trip.state).to eq('fulfilled')
      expect(bside4.trip.state).to eq('fulfilled')

      expect(aside1.fare).to eq(aside2.fare)
      expect(aside1.fare).to eq(aside3.fare)
      expect(aside1.fare).to eq(aside4.fare)

      expect(bside1.fare).to eq(bside2.fare)
      expect(bside1.fare).to eq(bside3.fare)
      expect(bside1.fare).to eq(bside4.fare)
    end
  end
end
