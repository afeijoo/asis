# frozen_string_literal: true

module API
  module V1
    class InstagramProfiles < Grape::API
      version 'v1'
      format :json

      resource :instagram_profiles do
        desc 'Return list of indexed Instagram profiles'
        get do
          InstagramProfile.all(sort: :username)
        end

        desc 'Create an Instagram profile and enqueue backfilling photos.'
        params do
          requires :id, type: Integer, desc: 'Instagram profile id.'
          requires :username, type: String, desc: 'Instagram profile username.'
        end
        post do
          instagram_profile = InstagramProfile.new(username: params[:username], id: params[:id])
          instagram_profile.save && InstagramPhotosImporter.perform_async(instagram_profile.id)
          instagram_profile
        end
      end
    end
  end
end
