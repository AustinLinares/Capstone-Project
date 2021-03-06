require "rails_helper"

describe "Subscribers", type: :request do
  before :all do
    Preference.create([{ name: "women" }, { name: "men" }, { name: "children" }])
    first_sub = Subscriber.new(email: "austin10@mail.com")
    first_sub.preferences << Preference.first
    first_sub.save
  end

  before :each do
    # Because the abstractapi only accepts one request per second to free users
    sleep 1
  end

  describe "new path" do
    it "respond with http success status code" do
      get "/subscribers/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "create path" do
    describe "respond with http unprocessable entity status code" do
      it "when email doesn't have email format" do
        post "/subscribers",
             params: { subscriber: { email: "austin", women: "1", men: "0", children: "0" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "when user doesn't choose any preference" do
        post "/subscribers",
             params: { subscriber: { email: "austin@mail.com", women: "0", men: "0",
                                     children: "0" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "when user's email is already subscribed" do
        post "/subscribers",
             params: { subscriber: { email: "austin10@mail.com", women: "1", men: "0",
                                     children: "1" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "when abstract_api email quality score is under 0.70" do
        # "linaresaustin@hotmail.com" returns a quality score of 0.00
        post "/subscribers",
             params: { subscriber: { email: "linaresaustin@hotmail.com", women: "1", men: "0",
                                     children: "1" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "when a correct request is send" do
      it "respond with http created status code" do
        post "/subscribers",
             params: { subscriber: { email: "austin@mail.com", women: "0", men: "1",
                                     children: "0" } }
        expect(response).to have_http_status(:see_other)
      end

      it "respond with the corrrect email" do
        data = { email: "austin@mail.com", women: "0", men: "1", children: "0" }
        post "/subscribers", params: { subscriber: data }
        expect(Subscriber.last[:email]).to eq(data[:email])
      end

      it "respond with the correct preference" do
        data = { email: "austin2@mail.com", women: "1", men: "0", children: "0" }
        post "/subscribers", params: { subscriber: data }
        last_sub = Subscriber.last
        expect(last_sub.preferences[0][:name]).to eq("women")
      end
    end
  end
end
