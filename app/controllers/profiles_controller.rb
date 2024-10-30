class ProfilesController < ApplicationController
  def index
    profiles = Profile.all
    profiles_with_avatar = profiles.map { |pro| profile_with_avatar(pro) }
    render json: profiles_with_avatar, status: :ok
  end

  def update
    profile = Profile.find(params[:id])

    if profile.update(profile_params)
      render json: { profile: profile, message: 'Profile updated :)' }, status: :ok
    else
      render json: { errors: profile.errors }, status: :unprocessable_entity
    end
  end

  def update_profile_picture
    profile = Profile.find(params[:id])
    blob = ActiveStorage::Blob.find_signed(params[:blob_id])

    if profile.update(avatar: blob) && profile.update(picture: url_for(profile.avatar))
      render json: { message: 'profile picture was updated successfully' }, status: :ok
    else
      render json: { message: profile.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :display_name, :picture, :title, :phone, :email, :avatar)
  end

  def profile_with_avatar(profile)
    json_profile = profile.as_json
    json_profile_with_avatar = {
      **json_profile, avatar: profile.avatar.attached? ? url_for(profile.avatar) : nil
    }
  end
end
