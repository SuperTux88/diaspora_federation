# frozen_string_literal: true

DiasporaFederation::Engine.routes.draw do
  controller :receive do
    post "receive/public" => :public, :as => "receive_public"
    post "receive/users/:guid" => :private, :as => "receive_private"
  end

  controller :fetch do
    get "fetch/:type/:guid" => :fetch, :as => "fetch", :guid => /#{Validation::Rule::Guid::VALID_CHARS}/
  end

  controller :webfinger do
    get ".well-known/webfinger" => :webfinger, :as => "webfinger"
  end

  controller :h_card do
    get "hcard/users/:guid" => :hcard, :as => "hcard"
  end
end
