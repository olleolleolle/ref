require 'test/unit'
require File.expand_path("../../lib/references", __FILE__)

module ReferenceValueMapBehavior
  def test_keeps_entries_with_strong_references
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      assert_equal value_1, hash["key 1"]
      assert_equal value_2, hash["key 2"]
    end
  end

  def test_removes_entries_that_have_been_garbage_collected
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      assert_equal "value 2", hash["key 2"]
      assert_equal "value 1", hash["key 1"]
      References::Mock.gc(value_2)
      assert_nil hash["key 2"]
      assert_equal value_1, hash["key 1"]
    end
  end

  def test_can_clear_the_map
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      hash.clear
      assert_nil hash["key 1"]
      assert_nil hash["key 2"]
    end
  end

  def test_can_delete_entries
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      References::Mock.gc(value_2)
      assert_nil hash.delete("key 2")
      assert_equal value_1, hash.delete("key 1")
      assert_nil hash["key 1"]
    end
  end

  def test_can_merge_in_another_hash
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      hash.merge!("key 3" => value_3)
      assert_equal "value 2", hash["key 2"]
      assert_equal value_1, hash["key 1"]
      References::Mock.gc(value_2)
      assert_nil hash["key 2"]
      assert_equal value_1, hash["key 1"]
      assert_equal value_3, hash["key 3"]
    end
  end

  def test_can_get_all_values
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      hash["key 3"] = value_3
      assert_equal ["value 1", "value 2", "value 3"].sort, hash.values.sort
      References::Mock.gc(value_2)
      assert_equal ["value 1", "value 3"].sort, hash.values.sort
    end
  end

  def test_can_turn_into_an_array
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      hash["key 3"] = value_3
      order = lambda{|a,b| a.first <=> b.first}
      assert_equal [["key 1", "value 1"], ["key 2", "value 2"], ["key 3", "value 3"]].sort(&order), hash.to_a.sort(&order)
      References::Mock.gc(value_2)
      assert_equal [["key 1", "value 1"], ["key 3", "value 3"]].sort(&order), hash.to_a.sort(&order)
    end
  end

  def test_can_iterate_over_all_entries
    References::Mock.use do
      hash = map_class.new
      value_1 = "value 1"
      value_2 = "value 2"
      value_3 = "value 3"
      hash["key 1"] = value_1
      hash["key 2"] = value_2
      hash["key 3"] = value_3
      keys = []
      values = []
      hash.each{|k,v| keys << k; values << v}
      assert_equal ["key 1", "key 2", "key 3"], keys.sort
      assert_equal ["value 1", "value 2", "value 3"], values.sort
      References::Mock.gc(value_2)
      keys = []
      values = []
      hash.each{|k,v| keys << k; values << v}
      assert_equal ["key 1", "key 3"], keys.sort
      assert_equal ["value 1", "value 3"], values.sort
    end
  end

  def test_inspect
    References::Mock.use do
      hash = map_class.new
      hash["key 1"] = "value 1"
      assert hash.inspect
    end
  end
end