require 'rails_helper'

RSpec.describe ClueController, :type => :controller do
  describe 'GET random' do
    it 'responds with a JSON clue' do
      create(:clue)

      get :random

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['text']).to eq('text')
    end
  end
end
