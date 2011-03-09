require "#{File.dirname(__FILE__)}/spec_helper"

include Beerxml

describe "Centennial Blonde" do
  before(:each) do
    # http://www.homebrewtalk.com/f66/centennial-blonde-simple-4-all-grain-5-10-gall-42841/
    @recipe = Recipe.new(:name => 'Centennial Blonde',
                         :type => 'All Grain',
                         :brewer => 'BierMuncher',
                         :batch_size => 5.5.gallons,
                         :boil_size => 6.75.gallons,
                         :boil_time => 60.minutes,
                         :efficiency => 70.0)
    @recipe.hops << Hop.new(:name => 'Centennial',
                            :alpha => 9.5,
                            :amount => 0.25.oz,
                            :use => 'Boil',
                            :time => 55)
    @recipe.hops << Hop.new(:name => 'Centennial',
                            :alpha => 9.5,
                            :amount => 0.25.oz,
                            :use => 'Boil',
                            :time => 35)
    @recipe.hops << Hop.new(:name => 'Cascade',
                            :alpha => 7.8,
                            :amount => 0.25.oz,
                            :use => 'Boil',
                            :time => 20)
    @recipe.hops << Hop.new(:name => 'Cascade',
                            :alpha => 7.8,
                            :amount => 0.25.oz,
                            :use => 'Boil',
                            :time => 5)
    @recipe.fermentables << Fermentable.new(:name => 'Pale Malt (2 Row)',
                                            :type => 'Grain',
                                            :amount => 7.pounds,
                                            :ppg => 37,
                                            :color => 2)
    @recipe.fermentables << Fermentable.new(:name => 'Cara-Pils',
                                            :type => 'Grain',
                                            :amount => 0.75.lb,
                                            :ppg => 33,
                                            :color => 2)
    @recipe.fermentables << Fermentable.new(:name => 'Crystal 10L',
                                            :type => 'Grain',
                                            :amount => 0.5.pounds,
                                            :ppg => 35,
                                            :color => 10)
    @recipe.fermentables << Fermentable.new(:name => 'Vienna',
                                            :type => 'Grain',
                                            :amount => U(0.5, 'lb'),
                                            :ppg => 35,
                                            :color => 4)
    @recipe.yeasts << Yeast.new(:name => 'Nottingham',
                                :type => 'Ale',
                                :form => 'Dry',
                                :amount => 0.2.liters,
                                :attenuation => 75)
    @recipe.should be_valid
  end

  it "should calculate basic stats" do
    @recipe.ibus.round.should == 20
    @recipe.calculate_og.should == 1.041
    @recipe.calculate_fg.should == 1.010
    @recipe.color == 3.9
  end

  it "should survive the serialization round trip" do
    xml = Nokogiri::XML(@recipe.to_xml)
    r2 = Recipe.new.from_xml(xml.root)
    r2.should be_valid
    r2.attributes.should == @recipe.attributes
    r2.each_beerxml_relationship do |rel|
      r2.send(rel.name).map(&:attributes).should == @recipe.send(rel.name).map(&:attributes)
    end
  end

  it "should calculate basic stats for the extract version" do
    @extract = Recipe.new(:name => 'Centennial Blonde',
                          :type => 'Extract',
                          :brewer => 'BierMuncher',
                          :batch_size => U(5.5, 'gallons'),
                          :boil_size => U(6.75, 'gallons'),
                          :boil_time => U(60, 'minutes'),
                          :efficiency => 70.0)
    @extract.hops.concat @recipe.hops
    @extract.yeasts.concat @recipe.yeasts
    @extract.fermentables << Fermentable.new(:name => 'Extra Light DME',
                                            :type => 'Dry Extract',
                                            :amount => U(5, 'lb'),
                                            :ppg => 43,
                                            :color => 3)
    @extract.fermentables << Fermentable.new(:name => 'Cara-Pils',
                                             :type => 'Grain',
                                             :amount => U(1, 'lb'),
                                             :ppg => 33,
                                             :color => 2)
    @extract.should be_valid
    @extract.ibus.round.should == 20
    @extract.calculate_og.should == 1.043
    @extract.calculate_fg.should == 1.011
    @extract.color == 3.2
  end
end
