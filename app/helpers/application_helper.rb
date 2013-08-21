module ApplicationHelper

  MENU_OPTIONS_SETTINGS = { 
    :account_details                => {:value => 'Account Details', :link => '/account/details'},
    :payment_info                   => {:value => 'Payment Information', :link => '/account/payment-info'},
    :preferences                      => {:value => 'Preferences', :link => '/account/preferences'},    
    :school_and_work             => {:value => 'School & Work Information', :link => '/account/school-and-work'},
    :public_profile                   => {:value => 'Edit Public Profile', :link => '/account/public-profile'},
    :change_password            => {:value => 'Change Password', :link => '/account/change-password'}
  }

  MENU_OPTIONS_MY_STUFF = { 
    :messages                         => {:value => 'Messages', :link => '/messages/inbox'},
    :challenges  	                     => {:value => 'Challenges', :link => '/account/challenges'},
    :communities                   => {:value => 'Communities', :link => '/account/communities'},
    :challenges_as_admin      => {:value => 'Administer Challenges', :link => '/admin/challenges'}
  }

  MENU_OPTIONS_REFERRAL = { 
    :referred_members            => {:value => 'Referred Members', :link => '/account/referred-members'},
    :invite_friends                   => {:value => 'Invite Friends', :link => '/account/invite-friends'}
  }	

  MENU_OPTIONS_SUBMISSIONS = { 
    :outstanding_reviews        => {:value => 'Outstanding Reviews', :link => '/judging/outstanding-reviews'},
    :judging_queue                 => {:value => 'Judging Queue', :link => '/judging/judging-queue'}
  }		

  def profile_pic
    current_user.profile_pic ||= 'http://cs-public.s3.amazonaws.com/default_cs_member_image.png'
  end

  def build_menu(position, selected_item)
    content = '<ul class="links">'
    eval("MENU_OPTIONS_#{position.upcase}").each do |item,options|
      if item.to_s == selected_item
        content += "<li class='active'><a href='#{options[:link]}'>#{options[:value]}</a></li>"
      else
        content += "<li><a href='#{options[:link]}'>#{options[:value]}</a></li>"
      end
    end
    content += '</ul>'
    return content.html_safe
  end                          

  def content_wrapper(&block)
    content_tag(:div, class: "content-wrapper") do
      content_tag(:div, class: "container") do
        content_tag(:div, class: "row-fluid") do
          capture(&block) if block_given?
        end
      end
    end
  end

end