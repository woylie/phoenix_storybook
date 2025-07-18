defmodule TreeStorybook.BFolder do
  use PhoenixStorybook.Index

  def folder_name, do: "Config Name"
  def folder_open?, do: true
  def folder_index, do: 1

  def entry("all_types_component"), do: [name: "AllTypesComponent (b_folder)"]
  def entry("component"), do: [name: "Component (b_folder)"]
end
