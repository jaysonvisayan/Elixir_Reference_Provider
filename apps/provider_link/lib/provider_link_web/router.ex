defmodule ProviderLinkWeb.Router do
  use ProviderLinkWeb, :router

  if Mix.env == :dev || Mix.env == :test do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  else
    use Plug.ErrorHandler
    use Sentry.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :session_required do
    plug ProviderLink.Guardian.AuthPipeline.Browser
    plug ProviderLink.Guardian.AuthPipeline.Authenticate
    plug Auth.CurrentUser
  end

  pipeline :auth_layout do
    plug :put_layout, {ProviderLinkWeb.LayoutView, :auth}
  end

  pipeline :reg_layout do
    plug :put_layout, {ProviderLinkWeb.LayoutView, :reg}
  end

  pipeline :ex_layout do
    plug :put_layout, {ProviderLinkWeb.LayoutView, :ex}
  end

  pipeline :no_layout do
    plug :put_layout, {ProviderLinkWeb.LayoutView, :no}
  end

  pipeline :auth_api do
    plug :accepts, ["json", "json-api"]
    plug ProviderLink.Guardian.AuthPipeline.JSON
  end

  pipeline :token_required do
    plug Guardian.Plug.EnsureAuthenticated,
      handler: ProviderLinkWeb.Api.V1.SessionController
  end

  scope "/", ProviderLinkWeb do
    pipe_through [:browser, :ex_layout]# Use the default browser stack

    get "/loas/eligibility/:paylink_user_id", LoaController, :member_index
    get "/loas/eligibility/:paylink_user_id/:card_no", LoaController, :member_security_index
    get "/loas/eligibility/:paylink_user_id/:card_no/:code", LoaController, :member_security_index
    get "/loas/eligibility/details/:paylink_user_id/:full_name/:birth_date/:coverage", LoaController, :validate_member_no_session
    get "/members/eligibility/evoucher/:paylink_user_id/:evoucher_number/:coverage", MemberController, :validate_evoucher_no_session
    get "/loas/eligibility/card/:paylink_user_id/:number/with_loa_validation/:bdate/:coverage", LoaController, :validate_number_no_session
    post "/loas/:id/print_evoucher", LoaController, :print_original_evoucher
    get "/loas/:loe_no/show_loa_no_session/:paylink_user_id", LoaController, :show_no_session
    get "/loas/:loe_no/package_info_no_session/:verification/:paylink_user_id", LoaController, :package_info_no_session
    post "/loas/:id/package_info_no_session/:paylink_user_id", LoaController, :request_loa_acu_no_session
    get "/members/:id/member/validate/scan_id/:paylink_user_id", MemberController, :scan_no_session
    post "/members/:id/member/validate/scan_id/:paylink_user_id", MemberController, :scan_id_no_session
    get "/loas/:loe_no/cancel_no_session/:paylink_user_id", LoaController, :show_cancel
    get "/loas/:loe_no/cancel_loa_no_session/:paylink_user_id", LoaController, :cancel_loa_no_session
    get "/loas/:card_no/no_session", LoaController, :get_member_by_card_no
    get "/loas/:card_no/attempt_no_session", LoaController, :attempt_expiry
    ### for all landing page of no_session
    get "/loas/eligibility/:paylink_user_id/:card_no/:verification", LoaController, :no_session_for_all

    # ACU Schedules no session
    # get "/paylink/:paylink_user_id/acu_schedules/", AcuScheduleController, :index
    # get "/paylink/:paylink_user_id/acu_schedules/:id/members", AcuScheduleController, :member_index
    # get "/paylink/:paylink_user_id/acu_schedules/:id/upload", AcuScheduleController, :render_upload
    post "/loas/:id/verified", LoaController, :verified_loa

    post "/loas/add_photo_no_session", LoaController, :add_photo_no_session
    post "/loas/capture_photo_no_session", LoaController, :capture_photo_no_session
    post "/loas/capture_facial_no_session", LoaController, :capture_facial_no_session
  end

  scope "/", ProviderLinkWeb do
    pipe_through [:browser, :no_layout] # Use the default browser stack
    get "/members/eligibility/:paylink_user_id/:card_no", MemberController, :index_no_session
  end

  scope "/", ProviderLinkWeb do
    pipe_through [:browser, :auth_layout] # Use the default browser stack

    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
    get "/forgot_password", SessionController, :forgot_password
    get "/forgot_password/mobile_verification", SessionController, :mobile_verification
    post "/forgot_password/mobile_verification", SessionController, :mobile_verification
    # post "/forgot_password", SessionController, :send_verification
    post "/forgot_password/verify", SessionController, :verify_code
    post "/forgot_password", SessionController, :send_verification
    get "/reset_password/:id", UserController, :reset_password
    post "/reset_password/:id", UserController, :update_password

  end

  scope "/", ProviderLinkWeb do
    pipe_through [:browser, :reg_layout] # Use the default browser stack

    get "/hidden_sign_up", AgentController, :new # Temporary change of route name
    post "/hidden_sign_up", AgentController, :create # Tempory change of route name

    get "/activate/:id", UserController, :new
    post "/activate/user/validate_username", UserController, :validate_username
    post "/activate/:id", UserController, :send_activation_code
    post "/activate/:id/verify", UserController, :create
    post "/activate/:id/new_code", UserController, :send_new_code
  end

  scope "/", ProviderLinkWeb do
    pipe_through [:browser, :session_required] # Use the default browser stack
    # Users
    get "/change_password/:id", UserController, :change_password
    post "/change_password/:id", UserController, :submit_change_password
    get "/", PageController, :index

    delete "/sign_out", SessionController, :delete

    get "/loas", LoaController, :index
    get "/loas/:id/request/consult", LoaController, :consult
    put "/loas/:id/update/consult", LoaController, :update_consult
    post "/loas/:id/update/consult", LoaController, :update_consult
    get "/loas/:id/request/lab", LoaController, :lab
    put "/loas/:id/update/lab", LoaController, :update_lab
    post "/loas/:id/update/lab", LoaController, :update_lab
    post "/loas/:id/update/diagnosis", LoaController, :update_diagnosis
    get "/loas/:id/request/ip", LoaController, :ip
    get "/loas/:id/request/er", LoaController, :er
    get "/loas/:id/request/peme", LoaController, :peme
    get "/loas/:id/show", LoaController, :show
    get "/loas/:id/show_consult", LoaController, :show_consult
    get "/loas/:id/show_peme", LoaController, :show_peme
    get "/loas/:id/show_consult/show_success", LoaController, :show_consult_success
    get "/loas/:id/cancel", LoaController, :cancel_loa
    post "/loas/:id/cancel", LoaController, :cancel_loa
    get "/loas/:id/cancel/peme", LoaController, :cancel_peme_loa
    get "/loas/cancel/peme", LoaController, :redirect_peme_cancel
    post "/loas/:id/cancel/peme", LoaController, :cancel_peme_loa
    get "/loas/search/consult", LoaController, :search_consult
    get "/loas/search/lab", LoaController, :search_lab
    get "/loas/search/acu", LoaController, :search_acu
    get "/loas/search/peme", LoaController, :search_peme
    get "/loas/:id/package_info/:verification", LoaController, :package_info
    get "/loas/:card_no/package_info/:verification/:loa_id", LoaController, :package_info
    post "/loas/:id/package_info", LoaController, :request_loa_acu
    post "/loas/:id/package_info/verify/:coverage", LoaController, :submit_loa_peme
    get "/loas/:id/show_otp", LoaController, :show_otp
    post "/loas/:id/print_evoucher", LoaController, :print_original_evoucher
    get "/loas/:id/verification/card_no_cvv", LoaController, :card_no_cvv_verify
    get "/loas/:id/get_expiry", LoaController, :get_expiry
    get "/loas/validate_pin/:id/:pin", LoaController, :validate_pin
    get "/loas/:id/send_pin", LoaController, :send_pin
    get "/loas/:id/show_verified", LoaController, :show_verified
    put "/loas/:id/request_peme", LoaController, :request_peme
    get "/loas/:id/reschedule_loa", LoaController, :reschedule_loa
    post "/loas/save_discharge_date", LoaController, :save_discharge_date
    get "/loas/:value/search_loa", LoaController, :search_loa
    ### for loa cart
    get "/loas/show_loa_cart", LoaController, :show_loa_cart
    delete "/loas/:id/remove_cart", LoaController, :remove_to_cart_page


    get "/members/index", MemberController, :index
    get "/loas/:card_no/:verification/redirect/:coverage/", LoaController, :redirect_with_session
    get "/loas/:id/:verification/redirect_peme/:coverage/", LoaController, :redirect_peme_with_session
    post "/members/member_authentication", MemberController, :member_authentication
    get "/loas/validate_accountlink_evoucher/:evoucher", LoaController, :validate_accountlink_evoucher
    post "/loas/validate_accountlink_evoucher/qrcode", LoaController, :validate_accountlink_qrcode
    get "/loas/card/:number/with_loa_validation/:bdate/:coverage", LoaController, :validate_member_by_card_number
    post "/members/request", MemberController, :request
    get "/members/:id/send_pin", MemberController, :send_pin
    get "/members/pin/:id/:pin", MemberController, :validate_pin
    get "/members/:code/account_code", MemberController, :get_member_by_account_code
    get "/members/:id/validate/accountlink_member", MemberController, :validate_accountlink_member
    post "/members/:id/update/accountlink_member", MemberController, :update_accountlink_member
    get "/loas/:card_no/attempt", LoaController, :attempt_expiry
    get "/loas/:full_name/:birth_date/:coverage", LoaController, :validate_member_by_details
    get "/members/:id/get_all_mobile_no", MemberController, :get_all_mobile_no
    get "/members/principal/get_all_mobile_no", MemberController, :get_all_mobile_no
    get "/members/:member_id/create_mobile_no", MemberController, :new_create_mobile_no
    post "/members/:member_id/create_mobile_no", MemberController, :create_mobile_no
    get "/members/:member_id/update_mobile_no", MemberController, :new_update_mobile_no
    put "/members/:member_id/update_mobile_no", MemberController, :update_mobile_no
    get "/members/validate/evoucher/:evoucher_number/verification", MemberController, :validate_evoucher
    get "/members/:id/member/validate/scan_id/session/:coverage", MemberController, :scan
    post "/members/:id/member/validate/scan_id/session/:coverage", MemberController, :scan_id
    get "/members/validate_evoucher", MemberController, :validate_evoucher
    get "/loas/:card_no", LoaController, :get_member_by_card_no
    put "/members/block/:id/attempt", MemberController, :blocked_member
    post "/loas/add_photo", LoaController, :add_photo
    post "/loas/capture_photo", LoaController, :capture_photo
    post "/loas/capture_facial", LoaController, :capture_facial

    # Verify LOA
    get "/loas/:id/verify/swipe_card/:card", LoaController, :verify_swipe_card
    get "/loas/:id/verify/cvv/:cvv", LoaController, :verify_cvv
    get "/loas/:facility_id/:name/filter_specializations", LoaController, :filter_doctor_specialization
    get "/loas/:facility_id/filter_all_specializations", LoaController, :filter_all_doctor_specialization
    get "/loas/:id/cancel_request", LoaController, :cancel_loa_request
    post "/loas/:id/verified/peme", LoaController, :verified_loa_peme

   #ACU Schedule
    get "/acu_schedules", AcuScheduleController, :index
    get "/acu_schedules/:id/members", AcuScheduleController, :member_index
    #post "/acu_schedules/create_schedule", AcuScheduleController, :create_schedule
    get "/acu_schedules/:id/upload", AcuScheduleController, :render_upload
    post "/acu_schedules/:id/submit_upload", AcuScheduleController, :submit_upload
    post "/acu_schedules/:id/cancel_upload", AcuScheduleController, :cancel_upload
    post "/acu_schedules/:id/update_member_schedule", AcuScheduleController, :update_member_schedule
    get "/acu_schedule_export", AcuScheduleController, :acu_schedule_download
    get "/acu_schedules/delete/xlsx", AcuScheduleController, :delete_xlsx
    get "/acu_schedules/:id/export", AcuScheduleController, :acu_schedule_export
    post "/acu_schedules/upload_member", AcuScheduleController, :upload_asm
    get "/acu_schedules/:log_id/download_member", AcuScheduleController, :download_asm
    get "/acu_schedules/:id/email_export", AcuScheduleController, :acu_schedule_email_export
    get "/acu_schedules/:id/show", AcuScheduleController, :show
    get "/acu_schedules/:id/export_member_details", AcuScheduleController, :export_member_details

    # Batch
    get "/batch", BatchController, :index
    get "/batch/new", BatchController, :new
    post "/batch/create", BatchController, :create
    get "/batch/:id/batch_details", BatchController, :batch_details
    get "/batch/:id/delete_batch", BatchController, :delete_batch
    get "/batch/:id/edit_soa/:amount", BatchController, :edit_soa
    get "/batch/loa/new", BatchController, :new_loa_batch
    post "/batch/loa/create", BatchController, :create_loa_batch
    get "/batch/:id/remove_to_batch/:loa_id", BatchController, :remove_to_batch
    get "/batch/:id/submit", BatchController, :submit_batch

    # Add_to_Cart
    # get "/loas/add_to_cart/:ids", LoaController, :add_to_cart
    post "/loas/add_to_cart", LoaController, :add_to_cart
    # get "/loas/add_to_batch/:ids", LoaController, :add_to_batch
    get "/loas/add_to_batch", LoaController, :add_to_batch
    post "/loas/add_to_batch", LoaController, :add_to_batch
    get "/loas/remove_to_cart/:id", LoaController, :remove_to_cart

  end

  # API
  scope "/api", ProviderLinkWeb.Api, as: :api do
    scope "/v1", V1 do
      pipe_through :auth_api

      get "/status", StatusController, :index
      post "/sign_in", SessionController, :login
      post "/user/forgot/password", SessionController, :forgot_password
      put "/user/forgot/password_confirm", SessionController, :forgot_password_confirm
      put "/user/forgot/password_reset", SessionController, :forgot_password_reset
      post "/user/forgot/resend_code", SessionController, :resend_code_api

      pipe_through :token_required
      # Token required end points

      put "/users", UserController, :user_update
      post "/user/match_user_payorlink", UserController, :match_user_payorlink
      post "/users", UserController, :get_users

      get "/sign_out", SessionController, :logout
      post "/loa/insert", LoaController, :create_loa
      put "/loas/:id/update_verified", AcuScheduleController, :update_acu_loa_verified
      put "/loas/:id/update_forfeited", AcuScheduleController, :update_acu_loa_forfeited
      post "/loas/acu/update_status", LoaController, :update_acu_loa_status

      # Provider
      get "/providers/insert_update_provider", ProviderController, :insert_update_provider

      post "/members/:member_id/registration", MemberController, :validate_member_registration
      post "/acu_schedules/update_member", AcuScheduleController, :update_member_registration
      post "/acu_schedules/update_availment", AcuScheduleController, :update_member_availment
      get "/providers/acu_schedules", ProviderController, :get_acu_schedules

      # Member
      post "/members/replicate_members", MemberController, :replicate_member

      #Role/Permission
      post "/roles/create_role_from_payorlink", RoleController, :create_role_api
      post "/permissions/create_permission_from_payorlink", RoleController, :create_permission_api
      post "/applications/create_application_from_payorlink", RoleController, :create_application_api
      put "/roles/:payorlink_role_id/update_role_from_payorlink", RoleController, :update_role_api

      # Session

      # ACU Schedule
      post "/acu_schedules/create_schedule", AcuScheduleController, :create_schedule
      post "/acu_schedules/:id/insert_schedule_member", AcuScheduleController, :insert_schedule_member
      post "/acu_schedules/:id/insert_schedule_member_from_payorlink", AcuScheduleController, :insert_schedule_member_from_payorlink
      get "/acu_schedules/get_by_provider_code", AcuScheduleController, :get_acu_schedules_by_provider_code
      get "/acu_schedules/get_by_batch_no", AcuScheduleController, :get_by_batch_no
      put "/acu_schedules/:id/submit_batch", AcuScheduleController, :submit_batch
      post "/acu_schedules/attach_soa", AcuScheduleController, :attach_soa_to_batch
      get "/acu_schedules/:batch_no/view_soa", AcuScheduleController, :view_soa
      post "/claims/insert", AcuScheduleController, :create_claims
      post "/acu_schedules/create_batch", AcuScheduleController, :acu_schedule_create_batch
      post "/acu_schedules/submit_batch", AcuScheduleController, :acu_schedule_submit_batch
      post "/acu_schedules/attach_soa_v2", AcuScheduleController, :attach_soa_to_batch_v2
      get "/acu_schedules/check_progress", AcuScheduleController, :acu_schedule_check_progress
      post "/batch/attach_soa", BatchController, :attach_soa_to_batch
      put "/acu_schedules/hide", AcuScheduleController, :hide_acu_schedule

      # api email
      post "/email/send_acu_email", EmailController, :send_acu_email
      # PEME
      post "/peme/insert_loa", LoaController, :create_loa_peme_from_accountlink

      scope "/migration", Migration do
        post "/users/batch/create", UserController, :create_batch_user
        post "/job/users/batch/create", UserController, :job_create_batch_user
      end
    end
  end
end
