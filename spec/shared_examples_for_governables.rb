shared_examples "a governable object" do
  before do
    @publicReadAdminPolicy = AdminPolicy.new(label: 'Public Read')
    @publicReadAdminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS,
                                                  DulHydra::Permissions::READER_GROUP_ACCESS,
                                                  DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                                  DulHydra::Permissions::ADMIN_GROUP_ACCESS]
    @publicReadAdminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
    @publicReadAdminPolicy.save
    @restrictedReadAdminPolicy = AdminPolicy.new(label: 'Restricted Read')
    @restrictedReadAdminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS,
                                                      DulHydra::Permissions::READER_GROUP_ACCESS,
                                                      DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                                      DulHydra::Permissions::ADMIN_GROUP_ACCESS]
    @restrictedReadAdminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
    @restrictedReadAdminPolicy.save
    @registeredUser = User.create(email: 'registereduser@nowhere.org', password: 'sg%wvegfl')
    @repositoryReader = User.create(email: 'repositoryreader@nowhere.org', password: '87akfb3vs')
    @repositoryEditor = User.create(email: 'repositoryeditor@nowhere.org', password: 'kljhs5dnc')
    @governable = described_class.create
  end
  after do
    @publicReadAdminPolicy.delete
    @restrictedReadAdminPolicy.delete
    @registeredUser.delete
    @repositoryReader.delete
    @repositoryEditor.delete
    @governable.delete
  end
end
