ActiveAdmin.register AdminUser do
  menu priority: 14, label: "Admin Users"

  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  show do
    columns do
      column do
        panel "Account Details" do
          attributes_table_for admin_user do
            row :email
            row :created_at
            row :updated_at
          end
        end
      end

      column do
        panel "Sign In Activity" do
          attributes_table_for admin_user do
            row :current_sign_in_at
            row :sign_in_count
            row :reset_password_sent_at
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors

    columns do
      column do
        f.inputs "Account" do
          f.input :email
        end
      end

      column do
        f.inputs "Password" do
          f.input :password
          f.input :password_confirmation
        end
      end
    end

    f.actions
  end
end
