
describe "CDQ Query" do

  it "Should have a target and a scope" do
    @query = CDQ::Query.new(Article, "fake scope")
    @query.target.should == Article
    @query.target.should == "fake scope"
  end

end

