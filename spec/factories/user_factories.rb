READER = 'repositoryreader@nowhere.org'
EDITOR = 'repositoryeditor@nowhere.org'
ADMIN = 'repositoryadmin@nowhere.org'

FactoryGirl.define do

  factory :user do

    sequence(:username) { |n| "person#{n}" }
    email { |u| "#{u.username}@example.com" }
    password "secret"

    factory :reader do
      username READER
      email { |u| u.username }
    end

    factory :editor do
      username EDITOR
      email { |u| u.username }
    end

    factory :admin do
      username ADMIN
      email { |u| u.username }
    end

  end

end
