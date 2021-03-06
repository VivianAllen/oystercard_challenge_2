require 'oystercard'
  describe Oystercard do
    #oystercard = Oystercard.new
    subject(:oystercard) {described_class.new}
    subject(:oystercard_min) {described_class.new}
    subject(:oystercard_empty) {described_class.new}
    let(:station_dbl) { double(:station_dbl, name: "Paddington") }
    let(:station_dbl_2) { double(:station_dbl, name: "Waterloo") }

    before do
      oystercard.top_up(10)
      oystercard_min.top_up(1)
    end

    describe "check balance and enforce limits" do

      it 'should have a balance of 0 when initialized' do
        expect(oystercard_empty.balance).to eq 0
      end

      it 'should respond to #top_up by adding money to the balance' do
        expect { oystercard.top_up(10) }.to change {oystercard.balance}.by(10)
      end

      it 'should raise an error when exceed the limit' do
        expect { oystercard.top_up(100) }.to raise_error("Sorry, you've reached the limit of £#{Oystercard::DEFAULT_LIMIT}")
      end

      it 'should raise an error when below minimum balance' do
        expect { oystercard_empty.touch_in(station_dbl) }.to raise_error("Sorry, not enough credit in balance (£#{oystercard_empty.balance})")
      end

      it 'should NOT raise an error when at minimum balance' do
        expect { oystercard_min.touch_in(station_dbl) }.not_to raise_error
      end

      it 'should reduce the balance by minimum fare when touch_out' do
        expect { oystercard.touch_out(station_dbl) }.to change {oystercard.balance}.by(-1)
      end

    end

    describe "check and change card_status" do
      it "should start the journey when touch in" do
        oystercard.touch_in(station_dbl)
        expect(oystercard.in_journey?).to be_truthy
      end

      it 'should end the journey when touch out' do
        oystercard.touch_in(station_dbl)
        oystercard.touch_out(station_dbl)
        expect(oystercard.in_journey?).to be_falsey
      end

      it 'should be false when card_status is not_in_use' do
        expect(oystercard.in_journey?).to be_falsey
      end

      it 'should be true when card_status is in_use' do
        oystercard.touch_in(station_dbl)
        expect(oystercard.in_journey?).to be_truthy
      end
    end

    describe 'keep track of journey history' do
      it 'logs the entry station' do
        oystercard.touch_in(station_dbl)
        expect(oystercard.entry_station).to eq "Paddington"
      end

      it 'logs the exit station' do
        oystercard.touch_out(station_dbl_2)
        expect(oystercard.exit_station).to eq "Waterloo"
      end

      it 'entry station is nil once you exit station' do
        oystercard.touch_out(station_dbl_2)
        expect(oystercard.entry_station).to eq nil
      end

      it 'starts empty by default' do
        expect(oystercard.history).to eq []
      end


      it 'returns a single journey history' do
        oystercard.touch_in(station_dbl)
        oystercard.touch_out(station_dbl_2)
        expect(oystercard.history).to eq [{entry: "Paddington", exit: "Waterloo"}]
      end

      it 'returns multiple journey history' do
        oystercard.touch_in(station_dbl)
        oystercard.touch_out(station_dbl_2)
        oystercard.touch_in(station_dbl_2)
        oystercard.touch_out(station_dbl)
        expect(oystercard.history).to eq [{entry: "Paddington", exit: "Waterloo"}, {entry: "Waterloo", exit: "Paddington"}]
      end

    end

  end
