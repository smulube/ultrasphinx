
require "#{File.dirname(__FILE__)}/../integration_helper"

class SearchTest < Test::Unit::TestCase

  S = Ultrasphinx::Search

  def test_simple_query
    assert_nothing_raised do
      @q = S.new(:query => 'seller').run
    end
    assert_equal 20, @q.results.size
  end  
  
  def test_empty_query
    assert_nothing_raised do
      @q = S.new.run
    end
    assert_equal(
      User.count + Seller.count,
      @q.total_entries
    )
  end
  
  def test_sort_by_date
    assert_equal(
      Seller.find(:all, :limit => 5, :order => 'created_at DESC').map(&:created_at),
      S.new(:class_names => 'Seller', :sort_by => 'created_at', :sort_mode => 'descending', :per_page => 5).run.map(&:created_at)
    )
  end

  def test_sort_by_float
    assert_equal(
      Seller.find(:all, :limit => 5, :order => 'capitalization ASC').map(&:capitalization),
      S.new(:class_names => 'Seller', :sort_by => 'capitalization', :sort_mode => 'ascending', :per_page => 5).run.map(&:capitalization)
    )
  end
 
  def test_filter
    assert_equal(
      Seller.count(:conditions => 'user_id = 17'),
      S.new(:class_names => 'Seller', :filters => {'user_id' => 17}).run.size
    )
  end
  
  def test_float_range_filter
    @count = Seller.count(:conditions => 'capitalization <= 29.5 AND capitalization >= 10')
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'capitalization' => 10..29.5}).run.size)
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'capitalization' => 29.5..10}).run.size)
  end

  def test_date_range_filter
    @first, @last = Seller.find(5).created_at, Seller.find(10).created_at
    @count = Seller.count(:conditions => ['created_at <= ? AND created_at >= ?', @first, @last])
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'created_at' => @first..@last}).run.size)
    assert_equal(@count,
      S.new(:class_names => 'Seller', :filters => {'created_at' => @last..@first}).run.size)
  end
    
  def test_text_filter
    assert_equal(
      Seller.count(:conditions => "company_name = 'seller17'"),
      S.new(:class_names => 'Seller', :filters => {'company_name' => 'seller17'}).run.size
    )  
  end
  
  def test_invalid_filter
    assert_raises(Sphinx::SphinxArgumentError) do
      S.new(:class_names => 'Seller', :filters => {'bogus' => 17}).run
    end
  end
  
  def test_query_filter
  
  end
  
  def test_weighting
  
  end
  
end