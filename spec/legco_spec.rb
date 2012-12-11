require "#{File.dirname(__FILE__)}/../lib/legco"

describe "Legco" do
  describe "#members" do
    it "should list members" do
      members = Legco.members
      members.class.should == Array
      members.size.should > 0

      [:name, :image, :url, :region].each do |k|
        members[0][k].should_not be_nil
      end
    end
  end
end