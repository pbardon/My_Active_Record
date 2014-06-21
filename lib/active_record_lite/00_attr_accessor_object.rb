class AttrAccessorObject
  def self.my_attr_accessor(*names)
    ivar_names = names.map{ |name| (name.to_s) }
    ivar_names.each do |name|
      define_method "#{name}" do
        name = name.to_s
        instance_variable_get('@' + name)
      end
      define_method "#{name}=" do |set|
        instance_variable_set('@' + name, set)
      end
    end
  end
end