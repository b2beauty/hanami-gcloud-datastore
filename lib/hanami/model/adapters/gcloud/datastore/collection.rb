module Hanami
  module Model
    module Adapters
      module Gcloud
        module Datastore
          # Maps a Datastore dataset and perfoms manipulations on it.
          #
          # @api private
          # @since 0.1.0
          #
          # @see http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore/Dataset.html
          # @see http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore/Query.html
          class Collection
            # Initialize a collection
            #
            # @param dataset [Gcloud::Datastore::Dataset] the dataset that maps
            #   a table or a subset of it.
            # @param mapped_collection [Hanami::Model::Mapping::Collection] a
            #   mapped collection
            #
            # @return [Hanami::Model::Adapters::Gcloud::Datastore::Collection]
            #
            # @api private
            # @since 0.1.0
            def initialize(dataset, mapped_collection)
              @dataset, @mapped_collection = dataset, mapped_collection
            end

            # Creates a entity for the given hanami entity and assigns an id.
            #
            # @param entity [Object] the entity to persist
            #
            # @see Hanami::Model::Adapters::Gcloud::Datastore::Command#create
            #
            # @return the primary key of the created record
            #
            # @api private
            # @since 0.1.0
            def insert(entity)
              persist_entity = @dataset.entity key_for(entity)
              _serialize(entity).each_pair do |key, value|
                persist_entity[key.to_s] = value
              end

              entity.id = @dataset.save(persist_entity).first.key.id
              entity
            end

            private

            # Return datastore key for entity
            #
            # @return [Gcloud::Datastore::Key] entity key
            #
            # @api private
            # @since 0.1.0
            def key_for(entity)
              @dataset.key @mapped_collection.name.to_s, entity.id
            end

            # Serialize the given entity before to persist in the datastore.
            #
            # @return [Hash] the serialized entity
            #
            # @api private
            # @since 0.1.0
            def _serialize(entity)
              @mapped_collection.serialize(entity)
            end
          end
        end
      end
    end
  end
end
