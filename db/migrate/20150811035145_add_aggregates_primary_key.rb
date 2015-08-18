class AddAggregatesPrimaryKey < ActiveRecord::Migration
  def change
		Aggregate.connection.execute("ALTER TABLE aggregates ADD PRIMARY KEY (id)")
  end
end
