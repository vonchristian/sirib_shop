module ApplicationHelper
  def money(cents, currency = current_business&.currency || "PHP")
    return "—" if cents.nil?

    amount = (cents.to_i / 100.0)
    formatted = format("%0.2f", amount)
    "#{currency} #{formatted}"
  end

  def money_input_value(cents)
    cents.to_i.zero? ? "" : format("%0.2f", cents.to_i / 100.0)
  end

  def nav_link(path, label, icon: nil, badge: nil, **options)
    active = current_page?(path) || (path != "/" && request.path.start_with?(path))
    classes = active ? "bg-teal-50 text-teal-700 border-teal-200" : "text-gray-600 hover:bg-gray-100 hover:text-gray-900 border-transparent"

    content_tag(:a, href: path, class: "flex items-center justify-between gap-x-3 border rounded-sm py-2 px-3 text-sm font-medium #{classes} #{options[:class]}") do
      content_tag(:span, class: "flex items-center gap-x-3") do
        (raw(icon) + content_tag(:span, label)).to_s.html_safe
      end + (badge ? content_tag(:span, badge, class: "inline-flex items-center px-2 py-0.5 text-xs font-semibold rounded-full bg-teal-100 text-teal-700") : "".html_safe)
    end
  end

  def icon(name, class_name = "shrink-0 size-4")
    icons = {
      home: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75"/></svg>',
      box: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="m21 7.5-9-5.25L3 7.5m18 0-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9"/></svg>',
      cube: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M6.429 9.75 12 12.75m0 0 5.571-3m-5.571 3v6.75m0-6.75L6.429 9.75m11.142 0L12 12.75m5.571-3L12 3.75 6.429 9.75m11.142 0L12 12.75m0 6.75H12"/></svg>',
      tag: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M9.568 3H5.25A2.25 2.25 0 0 0 3 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 0 0 5.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 0 0 9.568 3Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M6 6h.008v.008H6V6Z"/></svg>',
      cart: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"/></svg>',
      receipt: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M9 14.25 6.75 12m0 0L4.5 14.25M6.75 12v4.5m3-9.75 2.25 2.25m0 0 2.25-2.25M18.75 19.5V4.5a1.5 1.5 0 0 0-1.5-1.5H6.75a1.5 1.5 0 0 0-1.5 1.5v15a.75.75 0 0 0 1.5 0v-3h13.5v3a.75.75 0 0 0 1.5 0Z"/></svg>',
      arrow_left: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18"/></svg>',
      arrow_right: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg>',
      wrench: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M11.42 15.17 17.25 21A2.652 2.652 0 0 0 21 17.25l-5.877-5.877M11.42 15.17l2.496-3.03c.317-.384.74-.626 1.208-.766M11.42 15.17l-4.655 5.653a2.548 2.548 0 1 1-3.586-3.586l6.837-5.63m5.108-.233c.55-.164 1.163-.188 1.743-.14a4.5 4.5 0 0 0 4.486-6.336l-3.276 3.277a3.004 3.004 0 0 1-2.25-2.25l3.276-3.276a4.5 4.5 0 0 0-6.336 4.486c.091 1.076-.071 2.264-.904 2.95l-.102.085"/></svg>',
      cash: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z"/></svg>',
      book: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25"/></svg>',
      users: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"/></svg>',
      building: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21M3 3h12m-.75 4.5H21m-3.75 3.75h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Z"/></svg>',
      truck: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>',
      shopping_bag: '<svg class="shrink-0 size-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 10.5V6a3.75 3.75 0 1 0-7.5 0v4.5m11.356-1.993 1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 0 1-1.12-1.243l1.264-12A1.125 1.125 0 0 1 5.513 7.5h12.974c.576 0 1.059.435 1.119 1.007ZM8.625 10.5a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm7.5 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z"/></svg>'
    }
    raw(icons.fetch(name.to_sym, icons[:box]))
  end

  def page_header(title, subtitle: nil, &actions)
    content_tag(:div, class: "sm:flex sm:items-center sm:justify-between mb-6") do
      content_tag(:div) do
        content_tag(:h1, title, class: "text-2xl font-bold text-gray-900 tracking-tight") +
          (subtitle ? content_tag(:p, subtitle, class: "mt-1 text-sm text-gray-500") : "")
      end +
        (actions ? content_tag(:div, class: "mt-4 sm:mt-0 flex gap-2", &actions) : "")
    end
  end

  def card(&block)
    content_tag(:div, class: "bg-white rounded-xl border border-gray-200 shadow-sm", &block)
  end

  def status_badge(record, column: :status)
    value = record.public_send(column)
    label = record.public_send(column).to_s.tr("_", " ").titleize

    colors = {
      active: "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
      available: "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
      completed: "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
      confirmed: "bg-blue-50 text-blue-700 ring-blue-600/20",
      submitted: "bg-blue-50 text-blue-700 ring-blue-600/20",
      received: "bg-teal-50 text-teal-700 ring-teal-600/20",
      open: "bg-sky-50 text-sky-700 ring-sky-600/20",
      draft: "bg-gray-100 text-gray-700 ring-gray-600/20",
      pending: "bg-amber-50 text-amber-700 ring-amber-600/20",
      sold: "bg-indigo-50 text-indigo-700 ring-indigo-600/20",
      repairing: "bg-violet-50 text-violet-700 ring-violet-600/20",
      released: "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
      ready: "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
      cancelled: "bg-rose-50 text-rose-700 ring-rose-600/20",
      failed: "bg-rose-50 text-rose-700 ring-rose-600/20",
      inactive: "bg-gray-100 text-gray-600 ring-gray-500/20",
      abandoned: "bg-gray-100 text-gray-600 ring-gray-500/20",
      reversed: "bg-rose-50 text-rose-700 ring-rose-600/20"
    }

    content_tag(:span, label,
                class: "inline-flex items-center gap-x-1.5 rounded-full px-2 py-1 text-xs font-medium ring-1 ring-inset #{colors.fetch(value.to_sym, "bg-gray-100 text-gray-700 ring-gray-600/20")}")
  end

  def enum_label(record, column)
    record.public_send(column).to_s.tr("_", " ").titleize
  end

  def format_asset_value(value)
    case value.service_asset_field.data_type
    when "boolean" then value.boolean_value? ? "Yes" : "No"
    when "date" then value.date_value ? l(value.date_value, format: :default) : "—"
    when "integer" then value.integer_value&.to_s || "—"
    when "decimal" then value.decimal_value ? format("%0.2f", value.decimal_value) : "—"
    else value.text_value.presence || "—"
    end
  end
end
