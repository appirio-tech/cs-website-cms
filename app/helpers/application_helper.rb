module ApplicationHelper

  MENU_OPTIONS_SETTINGS = { 
  	:account_details  				=> {:value => 'ACCOUNT DETAILS', 			:link => '/account/details'},
  	:payment_info		  				=> {:value => 'PAYMENT INFO', 				:link => '/account/payment-info'},
  	:school_and_work  				=> {:value => 'SCHOOL & WORK INFO', 	:link => '/account/school-and-work'},
  	:public_profile	  				=> {:value => 'PUBLIC PROFILE', 			:link => '/account/public-profile'},
		:change_password      		=> {:value => 'CHANGE PASSWORD',      :link => '/account/change-password'} 
	}

  MENU_OPTIONS_MY_STUFF = { 
  	:challenges  							=> {:value => 'CHALLENGES', 					:link => '/account/challenges'},
  	:challenges_as_admin			=> {:value => 'ADMIN CHALLENGES',			:link => '/account/challenges-admin'},
		:communities      				=> {:value => 'COMMUNITIES',  	  	  :link => '/account/communities'} 
	}	

  MENU_OPTIONS_REFERRAL = { 
  	:referred_members  				=> {:value => 'REFERRED MEMBERS', 		:link => '/account/referred-members'},
		:invite_friends      			=> {:value => 'INVITE FRIENDS',       :link => '/account/invite-friends'} 
	}	

  MENU_OPTIONS_SUBMISSIONS = { 
  	:outstanding_reviews			=> {:value => 'OUTSTANDING REVIEWS', 	:link => '/judging/outstandng-reviews'},
		:judging_queue      			=> {:value => 'JUDGING QUEUE',       	:link => '/judging/judging-queue'} 
	}		

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

end