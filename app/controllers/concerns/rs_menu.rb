module RsMenu
  extend ActiveSupport::Concern
  included do
    helper_method :navigation
  end

  def render_with_subs(menus, primary, item)
    subs = menus.select { |m| m.parent_id == item.id && !m.name.blank? }
    if subs.empty?
      block = Proc.new {}
    else
      block = Proc.new do |sub_nav|
        subs.each { |sub| render_with_subs(menus, sub_nav, sub) }
      end
    end
    cr = item.clean_regexp

    primary.item(
      item.slug,
      item.name,
      item.fullpath,
      &block
    )
  end

  def navigation(type)
    Proc.new do |primary|
      SimpleNavigation.config.autogenerate_item_ids = false
      menus = ::Menu.find(type).pages.to_a
      menus.select { |m| m.parent_id.nil? && !m.name.blank? }.each do |item|
        render_with_subs(menus, primary, item)
      end
    end
  end
end
