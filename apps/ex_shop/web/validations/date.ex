defmodule Validations.Date do
  import Ecto.Changeset, only: [validate_change: 3]

  def validate_not_past_date(changeset, field, options \\ []) do
    validate_gt_date(changeset, field, Ecto.Date.utc, [message: options[:message] || "can not be past date"])
  end

  # Better to add proper validation for Ecto.Date ref_date
  def validate_gt_date(changeset, field, ref_date, options \\ []) do
    # Handling ref_date nil cases
    # ref_date = ref_date || Ecto.Date.utc
    validate_change(changeset, field, fn _,value ->
      case Ecto.Date.compare(value, ref_date) do
        :lt -> [{field, options[:message] || "should be greater than #{Ecto.Date.to_string(ref_date)}"}]
        _  -> []
      end
    end)
  end

  def validate_lt_date(changeset, field, ref_date, options \\ []) do
    # Handling ref_date nil cases
    # ref_date = ref_date || Ecto.Date.load {9999,12,31}
    validate_change(changeset, field, fn _,value ->
      # Note the changed references
      case Ecto.Date.compare(ref_date, value) do
        :lt -> [{field, options[:message] || "should be less than #{Ecto.Date.to_string(ref_date)}"}]
        _  -> []
      end
    end)
  end
end
