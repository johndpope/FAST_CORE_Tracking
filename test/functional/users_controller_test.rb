require 'test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  
  fixtures :users,:accounts
  
    module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end
  
  def test_index
    get :index, {:id => 1}, {:user => users(:testuser), :user_id => users(:testuser), :account_id => accounts(:app)}
    assert_response :success
  end
  
  def test_edit_user
    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf", :is_admin => true}
    post :edit, {:id => 1, :user => params}, {:user => users(:testuser), :account_id => 1, :is_admin => users(:testuser).is_admin}
    assert_redirected_to :controller => "users"
    assert_equal "qwerty", User.find(1).first_name
    assert_equal true, User.find(1).is_admin
  end
  
  def test_edit_user_unauthorized
    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf"}
    post :edit, {:id => 2, :user => params}, {:user => users(:testuser), :account_id => 1}
    assert_redirected_to "/index"
    assert_not_equal "qwerty", User.find(2).first_name
  end
    
  def test_get_user
    get :edit, {:id => 1}, {:user => users(:testuser), :user_id => users(:testuser).id, :account_id => users(:testuser).account_id}
    assert_response :success
    user = assigns(:user)
    assert_equal "test", user.first_name
  end
  
  def test_get_user_unauthorized
    get :edit, {:id => 2}, {:user => users(:testuser), :user_id => users(:testuser).id, :account_id => users(:testuser).account_id}
    assert_redirected_to "/index"
    assert_nil assigns(:user)
  end
  
  def test_short_password
    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf"}
    post :edit, {:id => 1, :user => params, :password_checkbox => "checked", :existing_password => "test"}, {:user => users(:testuser), :account_id => 1, :is_admin => users(:testuser).is_admin}
    assert_redirected_to :controller => "users", :action => "edit", :id => 1
    assert_equal flash[:error], "Your existing password must match what's currently stored in our system"
  end
  
  def test_new_user
    get :new, {}, {:user => users(:testuser), :user_id => users(:testuser).id, :account_id => users(:testuser).account_id, :is_admin => users(:testuser).is_admin}
    assert_response :success
    params = {:first_name => "test", :last_name => "baldwin", :email => "dennisbaldwin@gmail.com", :password => "testing123", :password_confirmation => "testing123"}
    post :new, {:user => params}, {:user => users(:testuser), :account_id => 1, :user_id => users(:testuser).id}
    assert_redirected_to :controller => "users"
  end
  
  def test_new_user_email_exists
    params = {:first_name => "test", :last_name => "user", :email => "testuser@ublip.com", :password => "testing123", :password_confirmation => "testing123"}
    post :new, {:user => params}, {:user => users(:testuser), :account_id => 1, :user_id => users(:testuser).id, :is_admin => users(:testuser).is_admin}
    assert_response :success
    assert_equal flash[:error], "Email has already been taken<br />"
  end
  
  def test_delete
      #delete invalid record
      post :delete,{:id=>1}, {:user => users(:testuser), :user_id => users(:testuser).id, :account_id => users(:testuser).account_id}
      assert 302
      
      #delete valid record
      post :delete,{:id=>5}, {:user => users(:testuser), :user_id => users(:testuser).id, :account_id => users(:testuser).account_id}
      assert_redirected_to :controller => "users"
  end    
  
end
