READER_EMAIL = 'repositoryreader@nowhere.org'
EDITOR_EMAIL = 'repositoryeditor@nowhere.org'
ADMIN_EMAIL = 'repositoryadmin@nowhere.org'

FactoryGirl.define do

  factory :user do

    sequence(:email) { |n| "person#{n}@example.com" }
    password 'secret'

    factory :reader do
      email READER_EMAIL
    end

    factory :editor do
      email EDITOR_EMAIL
    end

    factory :admin do
      email ADMIN_EMAIL
    end

  end

end
