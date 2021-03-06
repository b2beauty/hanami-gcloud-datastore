require 'google/cloud/datastore'
require 'hanami/model/adapters/abstract'
require 'hanami/model/adapters/implementation'
require 'hanami/model/adapters/gcloud/datastore/collection'
require 'hanami/model/adapters/gcloud/datastore/command'
require 'hanami/model/adapters/gcloud/datastore/query'

module Hanami
  module Model
    module Adapters
      module Gcloud
        # Adapter for Google Cloud Datastore
        #
        # @api private
        # @since 0.1.0
        class DatastoreAdapter < Abstract
          include Implementation

          # Initialize the adapter.
          #
          # Hanami::Model uses Google::Cloud::Datastore.
          # For a complete reference of the connection please see:
          # http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/v0.20.1/google/cloud/datastore
          #
          # @param mapper [Object] the database mapper
          #
          # @return [Hanami::Model::Adapters::Gcloud::DatastoreAdapter]
          #
          # @see Hanami::Model::Mapper
          #
          # @api private
          # @since 0.1.0
          def initialize(mapper, uri, options = {})
            super

            @connection = Google::Cloud.new.datastore

            @collections = {}
          end

          # Creates an entity in the datastore for the given hanami entity.
          # It assigns the `id` attribute, in case of success.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param entity [#id=] the entity to create
          #
          # @return [Object] the entity
          #
          # @api private
          # @since 0.1.0
          def create(collection, entity)
            command(collection).create(entity)
          end

          # Updates an entity in the datastore corresponding to the given hanami entity.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param entity [Object] the entity to update
          #
          # @return [Object] the entity
          #
          # @since 0.1.0
          def update(collection, entity)
            command(collection).update(entity)
          end

          # Persists an entity in the datastore corresponding to the given hanami entity.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param entity [Object] the entity to persist
          #
          # @return [Object] the entity
          #
          # @since 0.1.0
          def persist(collection, entity)
            command(collection).persist(entity)
          end

          # Returns an unique record from the given collection, with the given
          # id.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param id [Object] the identity of the object.
          #
          # @return [Object] the entity or nil if not found
          #
          # @api private
          # @since 0.1.0
          def find(collection, id)
            command(collection).find(id)
          end

          # Returns a first record from the given collection.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          #
          # @return [Object] the entity or nil if not found
          #
          # @api private
          # @since 0.1.0
          def first(collection)
            command(collection).first
          end

          # Returns a last record from the given collection.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          #
          # @return [Object] the entity or nil if not found
          #
          # @api private
          # @since 0.1.0
          def last(collection)
            command(collection).last
          end

          def clear(_)
            raise NotImplementedError
          end

          def fetch(_)
            raise NotImplementedError
          end

          def execute(_)
            raise NotImplementedError
          end

          # Deletes a entity in the dataset corresponding to the given entity.
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param entity [Object] the entity to delete
          #
          # @since 0.1.0
          def delete(collection, entity)
            command(collection).delete(entity)
          end

          # Fabricates a command for the given query.
          #
          # @param query [Hanami::Model::Adapters::Gcloud::Datastore::Query] the
          #   query object to act on.
          #
          # @return [Hanami::Model::Adapters::Gcloud::Datastore::Command]
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Command
          #
          # @api private
          # @since 0.1.0
          def command(collection)
            Datastore::Command.new(_collection(collection))
          end

          # Fabricates a query
          #
          # @param collection [Symbol] the target collection (it must be mapped).
          # @param blk [Proc] a block of code to be executed in the context of
          #   the query.
          #
          # @return [Hanami::Model::Adapters::Gcloud::Datastore::Query]
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Query
          #
          # @api private
          # @since 0.1.0
          def query(collection, context = nil, &blk)
            Datastore::Query.new(
              @connection,
              _collection(collection),
              _mapped_collection(collection),
              &blk
            )
          end

          # Wraps the given block in a transaction (commit).
          #
          # @see Hanami::Repository::ClassMethods#transaction
          #
          # @since 0.1.0
          # @api private
          #
          def transaction(options = {})
            @connection.commit do
              yield
            end
          end

          private

          # Returns a collection from the given name.
          #
          # @param name [Symbol] a name of the collection (it must be mapped).
          #
          # @return [Hanami::Model::Adapters::Gcloud::Datastore::Collection]
          #
          # @see Hanami::Model::Adapters::Gcloud::Datastore::Collection
          #
          # @api private
          # @since 0.1.0
          def _collection(name)
            Datastore::Collection.new(@connection, _mapped_collection(name))
          end
        end
      end
    end
  end
end
