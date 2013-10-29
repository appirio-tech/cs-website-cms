# CloudSpokes Site with Refinery [![travis-ci](https://travis-ci.org/cloudspokes/cs-website-cms.png)](https://travis-ci.org/cloudspokes/cs-website-cms) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/cloudspokes/cs-website-cms)

This is the new cloudspokes.com website with Refinery using
the new [CloudSpokes API](https://github.com/cloudspokes/cs-api). 
If you would like to participate in challenges to build out the 
new site, fork this repo and get started.

## Database.com

While our front end is a rails app, most of the datastore and logic resides within our [Database.com org](http://database.com/). You can POST your CloudSpokes membername and password to the https://cs-api-sandbox.herokuapp.com/v1/accounts/authenticate endpoint and it will return an access token that you can use for subsequent calls to our API (passed in the header) or directly to database.com using the [Restforce gem](https://github.com/ejholmes/restforce). There are also a couple of rake tasks that will return an access token for you for testing.

## CloudSpokes API

We will be using our [new API](https://github.com/cloudspokes/cs-api) with this project so please check out the repo for info. There's not a ton of documentation at this time so you may need to check out the source code comments for samples or the specs (using VCR).

If your code is making any "destructive calls" (create, update, delete) with the new API, you will need to pass an API Key in the header of each request. Please email support@cloudspokes.com with the subject "Sandbox API Key Request for cs-website-cms" and we'll generate a key for you that will be good for all future challenges of this type.

## Local Development

We've recently switched to use [Foreman to develop locally](https://devcenter.heroku.com/articles/procfile) per Heroku's recommendation. We are also running [Postgres](http://postgresapp.com/) for development and test. You'll also need redis running locally as well. See .env-example for application specific variables that you need for your .env file. Please add any new variables to this example file. To get up and running, run:

	# fork this repo and clone
	bundle install
	rake db:create
	rake db:migrate
	rake db:seed
	touch .env
	# copy the contents from .env-example to .env
	# add the enviroment variables (see below)
	# remove the "worker" process types from the Procfile
	foreman start -p 3000

Once you get the application running, you can register for a new CloudSpokes member if necessary.

## Environment Variables

If any of your code requires direct calls to Database.com (e.g., pub/sub with faye) then you will need to setup the following environment variables. Please contact support@cloudspokes.com with the subject "Rails Sandbox Environment Variables Request" and we'll send them to you for all future challenges of this type.

	SFDC_CLIENT_ID
	SFDC_CLIENT_SECRET
	SFDC_PUBLIC_USERNAME
	SFDC_PUBLIC_PASSWORD
	CS_API_KEY

## Running Specs

Rspec uses VCR to make calls to the CloudSpokes API and caches them (as "casettes") for future tests. If you want to make new calls to the API instead of using the cassettes, simply delete the yaml file(s) in the /spec/fixtures/vcr_cassettes directories. 

It's a little difficult to test the API since it's not possible to setup/teardown tests in a Database.com sandbox. Therefore, these test may change over time but we'll try and keep them running as successfully as possible.

## Technical Specifications

Most of the action happens in the class ApiModel (found in app/models). It exposes an ActiveRecord-like DSL that uses the CloudSpokes API as the data source. Many of the ActiveRecord conveniences like #has_many and #column_names have been implemented and slightly modified to adapt as painlessly as possile to the backing API resource.

Note that this is not a 100% completely compatible implementation of ActiveRecord. For example, #belongs_to is not implemented (yet) so there is not an easy way to request the parent object from a collection (e.g. you can easily call challenge.participants but you cannot call as of yet challenge.participants.first.challenge -- there is no linkage in the direction of child to parent). However, based on a quick usage estimate, there is rarely any reason to request a child independent (or without foreknowledge) of its parent and eventually needing to figure out the parent object, so it's not that much pf an issue.

Models descend from ApiModel, which in turn implements the ActiveModel from Rails 4.0 -- this means that along with ActiveRecord DSL capabilities, an ApiModel is also compatible with ActionPack. That also means you can use it with view helpers such as form_for or url_for, simplifying routes.

To create a new model, first inherit from ApiModel and then implement #api_endpoint. Implementing #api_endpoint is important because some relationships that are not in the JSON sent by the api need to be resolved via calling the api. The nodel name is, by convention should be the same as the url endpoint you will be calling to request it (e.g. Participant -> /participants).

You'll then need to list out the attributes (via #attr_accessor) the model should be exposing. We don't have support for typecasting yet, so you'll have to implement your own typecasts as an accessor. For example:

	attr_accessor :start_date

	def start_date
		Date.parse @start_date.to_s if @start_date
	end

Objects are actually a [Hashie::Mash](http://rdoc.info/github/intridea/hashie/Hashie/Mash) giving the ability to do dot-notation calls for the fields.

An example scaffolding has been setup to showcase how easy it is to use the models from a view/controller perspective -- it simply behaves just like any other ActiveRecord object that a Rails developer migth expect.

#### save ####

The idea regarding saving records is simple. 'save' method determines whether the model is a new record or not. If model is new, it creates a model, if not, it updates model. 

	challenge = Challenge.new
	challenge.new_record?       # true
	challenge.save              # creates new challenge

	challenge = Challenge.first
	challenge.new_record?       # false
	challenge.save              # updates challenge

#### new_record?  ####
Model is regarded as new record if id attribute exists. This behavior can be modified by overriding 'new_record?' method from the sub-class.
  
#### update and create ####
'update' method sends put request with Authorization header. Content type is json. 'create' method sends post request. 

update and create methods have a different endpoint. Each of endpoint is set by 'update_endpoint' and 'create_endpoint'

#### update_endpoint and create_endpoint  ####
update_endpoint is used for update request. 
create_endpoint is used for create request.
Default is like REST. Those methods can be override form subclasses.

## Force.com Streaming API Support

See [Pub Sub with Force.com Streaming API](https://github.com/cloudspokes/cs-website-cms/wiki/Pub-Sub-with-Force.com-Streaming-API) for info on configuration and usage.

## Other

ActiveModel::Model was copied and pasted into app/models because [it will only be available in Rails 4.0](http://blog.plataformatec.com.br/2012/03/barebone-models-to-use-with-actionpack-in-rails-4-0/). If you're interested in implementing a model that is not backed by a database, and yet still responds just like any old ActiveRecord model, you should definitely look at ActiveModel!

## Contributors

* Jeff Douglas -> [jeffdonthemic](https://github.com/jeffdonthemic)
* peakpado -> [peakpado](https://github.com/peakpado)
* dineshmatta -> [dineshmatta](https://github.com/dineshmatta)
* parasquid -> [parasquid](https://github.com/parasquid)
* chang -> [aproxacs](https://github.com/aproxacs)
