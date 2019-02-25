defmodule WebCATWeb.InboxView do
  use WebCATWeb, :view

  def render_draft(draft) do
    tag_class =
      case draft.status do
        "unreviewed" -> "is-primary"
        "approved" -> "is-success"
      end

    ~E"""
    <div class="card">
      <header class="card-header">
        <div class="level">
          <div class="level-left">
            <div class="level-item">
              <div class="card-header-title">
                <ul>
                  <li><%= draft.student.first_name %> <%= draft.student.last_name %></li>
                  <li>Rotation <%= draft.rotation_group.rotation.number %> - Rotation group <%= draft.rotation_group.number %></li>
                </ul>
              </div>
            </div>
          </div>
          <div class="level-right">
            <div class="level-item">
              <div class="tags">
                <span class="tag <%= tag_class %>">
                  <%= humanize(draft.status) %>
                </span>
              </div>
            </div>
          </div>
        </div>
      </header>
      <div class="card-content">
        <%= draft.content %>
      </div>
    </div>
    """
  end
end
