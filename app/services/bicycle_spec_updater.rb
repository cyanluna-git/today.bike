class BicycleSpecUpdater
  def self.upsert_spec(bicycle:, component:, brand:, component_model:)
    spec = bicycle.bicycle_specs.find_or_initialize_by(component: component)
    spec.brand = brand
    spec.component_model = component_model
    spec.save!
    spec
  end
end
