require 'test_helper'
require 'devices_controller'

# Re-raise errors caught by the controller.
class DevicesController; def rescue_action(e) raise e end; end

class DevicesControllerTest < ActionController::TestCase

  fixtures :users,:devices,:accounts,:groups,:device_profiles
  
  module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end

  def setup
    @controller = DevicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end
  
  def test_index
    get :index, {}, { :user => users(:testuser), :account_id => 1}     
    assert_response :success            
  end

   def test_index_with_group_selection
     get :index, {:group_id => 1}, {:user => users(:testuser), :account_id => 1}
     devices = assigns(:devices)
     assert_equal 2, devices.size
   end

   def test_view
     get :view, {:id=>"2"},{:user => users(:testuser), :account_id => "1"} 
     assert_response :success     
   end
   
  def test_new_group 
     post :new_group, {:id => "7", :name=>"summer of code", :select_devices=>[4], :image_value=>"4", :account_id=>"1"}, {:user => users(:testuser), :account_id => "1"}          
     assert_equal "Group summer of code was successfully added",flash[:success]
     group=Group.find_by_name("summer of code")
     assert_equal group.name, "summer of code"            
     assert_redirected_to :controller => "devices", :action=>"groups"
  end
    
  def test_new_group_invalid
      post :new_group, {:id => "7", :name=>"", :select_devices=>nil, :image_value=>"4", :account_id=>"1"}, {:user => users(:testuser), :account_id => "1"}          
      assert_equal "Group name can't be blank <br/>You must select at least one device ",flash[:error]
      assert_redirected_to :controller => "devices", :action=>"new_group"
  end   
  
  def test_edits_group
     post :edits_group, {:id => "1", :name=>"summer of code", :select_devices=>[4], :image_value=>"4", :account_id=>"1"}, {:user => users(:testuser), :account_id => "1"}           
     assert_equal "Group summer of code was updated successfully ",flash[:success]
     group=Group.find_by_name("summer of code")
     assert_equal group.name, "summer of code"
     assert_redirected_to :controller => "devices", :action=>"groups"
  end

  def test_group_edits_for_group_id
      get :edits_group, {:group_id=>"1"}, {:user => users(:testuser), :account_id => "1"}          
      assert_equal 'Dennis', flash[:group_name]
  end
  
  def test_edits_group_invalid
      post :edits_group, {:id => "1", :name=>"", :select_devices=>nil, :image_value=>"4", :account_id=>"1"}, {:user => users(:testuser), :account_id => "1"}          
      assert_equal "Group name can't be blank <br/>You must select at least one device ",flash[:error]
      assert_redirected_to :controller => "devices", :action=>"edits_group", :group_id=>1
  end   

  def test_delete_group
      post :delete_group, {:id=>"1"}, { :user => users(:testuser), :account_id => "1"}
      assert_equal "Group Dennis was deleted successfully ", flash[:success]
      assert_redirected_to :controller => "devices", :action=>'groups'
  end   
  
  def test_groups
      get :groups, {}, { :user => users(:testuser), :account_id => "1"}
      assert_response :success
  end
  
  def test_index_notauthorized
    get :index
    assert_redirected_to :controller => "login"
  end
  
  def test_edit_post
    post :edit, {:id => "1", :device => {:name => "qwerty", :imei=>"000000"}}, { :user => users(:testuser), :account_id => "1", :is_admin => users(:testuser).is_admin}
    assert_equal devices(:device1).name, "qwerty"
    assert_equal devices(:device1).imei, "000000"
    assert_redirected_to :controller => "devices"
  end
  
  def test_edit_for_uniqueness_of_imei
     post :edit, {:id => "1", :device => {:name => "qwerty", :imei=>"551211"}}, { :user => users(:testuser), :account_id => "1", :is_admin => users(:testuser).is_admin}
     assert_equal flash[:error], "Imei has already been taken<br/>"    
  end
  
  def test_edit_post_unauthorized
    begin
      post :edit, {:id => "1", :device => {:name => "qwerty", :imei=>"000000"}}, { :user => users(:nick), :account_id => "2"}
    rescue ActiveRecord::RecordNotFound
      # Make sure the save didn't happen
      assert_not_equal devices(:device1).name, "qwerty"
      assert_not_equal devices(:device1).imei, "000000"
    end
  end
  
  def test_edit_get
    get :edit, {:id => "1"}, { :user => users(:testuser), :account_id => "1" }
    assert_equal devices(:device1).name, "device 1"
    assert_equal devices(:device1).imei, "1234"
    assert_response :success
  end
  
  def test_edit_get_unauthorized
    get :edit, {:id => "1"}, { :user => users(:nick), :account_id => "2" }
    assert_response 302
  end
  
  def test_admin_delete_device
    post :delete, {:id => "1"}, { :user => users(:testuser), :account_id => "1", :is_admin => users(:testuser).is_admin }
    assert_redirected_to :controller => "devices"
    assert_equal 2, devices(:device1).provision_status_id
  end
  
  def test_non_admin_delete_device
    post :delete, {:id => "1"}, { :user => users(:demo), :account_id => "1", :is_admin => users(:demo).is_admin }
    assert_redirected_to :controller => "devices"
    assert_equal flash[:error], "Invalid action."
    assert_equal 1, devices(:device1).provision_status_id
  end
  
  def test_delete_unauthorized
    post :delete, {:id => "1"}, { :user => users(:nick), :account_id => "2" }
    assert_response 302
    assert_not_equal devices(:device1).provision_status_id, 2
  end
  
  def test_choose_MT
    post :choose_MT, {:imei => "33333", :name => "device 1"}, { :user => users(:testuser), :account_id => "1" }
    assert_redirected_to :controller => "devices"
    assert_equal devices(:device5).provision_status_id, 1
    assert_equal devices(:device5).account_id, 1
  end
  
  def test_choose_new_MT
    post :choose_MT, {:imei => "314159", :name => "new device"}, { :user => users(:testuser), :account_id => "1" }
    assert_redirected_to :controller => "devices"
    newDevice = Device.find_by_imei("314159")
    assert_equal 1, newDevice.provision_status_id
    assert_equal 1, newDevice.account_id
    assert_equal 90, newDevice.online_threshold
  end

  def test_choose_already_provisioned
    post :choose_MT, {:imei => "1234"}, { :user => users(:testuser), :account_id => "1" }
    assert_equal flash[:error] , 'This device has already been added'
    assert_response :success
  end

  def test_search_devices
     get :search_devices, {:device_search=>'device'} , { :user => users(:testuser), :account_id => "1" }
     assert_response :success
  end
end
