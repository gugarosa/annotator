<template lang="pug">
  div.user-table
    div.columns.is-multiline
      div.column.is-12
        a.button.is-dark(v-on:click="createNewRoleMapping()")
          span.icon 
            span.fas.fa-plus
          span Adicionar Usuário

      div.column.is-12(v-if="newRoleMapping")
        div.box
          div.columns.is-multiline
            div.column
              b-field(
                label="Usuário"
                v-bind:type="{ 'is-danger': getAddUserMessage }"
                v-bind:message="getAddUserMessage"
              )
                b-select(
                  placeholder="Selecione um usuário..."
                  v-model="newRoleMapping.username"
                  v-on:input="option => {checkValidExistingUser(option);\
                    newRoleMapping.userid = option}"
                )
                  option(v-for="otherUser in otherUsers", v-bind:value="otherUser.id")
                    | {{ otherUser.username }}

            div.column
              b-field(label="Permissão")
                b-select(
                  placeholder="Selecione uma permissão..."
                  v-model="newRoleMapping.roleid"
                )
                  option(v-for="role in roles", v-bind:value="role.id", v-bind:key="role.id")
                    | {{ role.name }}
            div.column
              div.field
                label.label &nbsp;
                div.field.is-grouped
                  p.control
                    b-button(
                      type="is-dark"
                      v-on:click="addRoleMapping()"
                      v-bind:disabled="isDisabled"
                    )
                      span.icon 
                        span.fas.fa-plus
                      span Adicionar

                  p.control
                    b-button(v-on:click="cancelCreate()")
                      span.icon 
                        span.fas.fa-times
                      span Cancelar
    div.card
      b-table(v-bind:data="roleMappings", icon-pack="fas", default-sort="username", striped=true)
        template(slot-scope="props")
          b-table-column(field="username", label="Usuário", sortable="")
            | {{ props.row.username }}
          b-table-column(field="rolename", label="Permissão", sortable="")
            b-dropdown(aria-role="list")
              button.button.is-dark(slot="trigger")
                span {{ props.row.rolename }}
                b-icon(icon="chevron-down", pack="fas", size="is-small", custom-size="fa-xs")
              b-dropdown-item(
                v-for="otherRole in getOtherRoles(props.row.role)"
                v-bind:key="otherRole.id"
                aria-role="listitem"
                v-on:click="switchRole(props.row.user, otherRole.id)"
              )
                | {{ otherRole.name }}
          b-table-column(label="Ações")
            a.button.is-danger.is-outlined(v-on:click="removeRoleMapping(props.row.id)")
              span.icon
                i.fas.fa-trash
              span Remover
</template>

<style>
.user-table {
  padding: 40px 20px;
}

.user-table .table {
  width: 100%;
}

.user-table .card {
  padding: 20px 20px;
}

.user-table .has-addons {
  display: none;
}

</style>

<script>
import HTTP, { defaultHttpClient } from './http';

export default {
  data: () => ({
    input: '',
    project: Object,
    newRoleMapping: null,
    hasNewUserError: false,
    roleMappings: [],
    allUsers: [],
    otherUsers: [],
    roles: [],
  }),

  computed: {
    isDisabled() {
      return !this.newRoleMapping.userid || !this.newRoleMapping.roleid || this.hasNewUserError;
    },

    getAddUserMessage() {
      if (this.hasNewUserError) {
        return 'Não é um usuário existente!';
      }
      if (!this.otherUsers.length) {
        return 'Não existem mais usuários para serem adicionados!';
      }
      return null;
    },

  },

  created() {
    Promise.all([
      HTTP.get('roles'),
      defaultHttpClient.get('/v1/users'),
      defaultHttpClient.get('/v1/roles'),
    ]).then(([projectRoles, users, roles]) => {
      this.roleMappings = projectRoles.data;
      this.allUsers = users.data;
      this.otherUsers = this.getOtherUsers();
      this.roles = roles.data;
    });
  },

  methods: {
    createNewRoleMapping() {
      this.newRoleMapping = {
        userid: null,
        roleid: null,
        username: null,
      };
    },

    addRoleMapping() {
      HTTP.post('roles', { user: this.newRoleMapping.userid, role: this.newRoleMapping.roleid })
        .then((response) => {
          this.roleMappings.push(response.data);
          this.otherUsers = this.getOtherUsers();
          this.cancelCreate();
        });
    },

    checkValidExistingUser(inputValue) {
      this.hasNewUserError = !this.otherUsers.some(user => user.id === inputValue);
      return inputValue;
    },

    cancelCreate() {
      this.newRoleMapping = null;
    },

    removeRoleMapping(roleMappingId) {
      HTTP.delete(`roles/${roleMappingId}`).then(() => {
        this.roleMappings = this.roleMappings.filter(
          roleMapping => roleMapping.id !== roleMappingId,
        );
        this.otherUsers = this.getOtherUsers();
      });
    },

    switchRole(userId, newRoleId) {
      const currentRoleMapping = this.roleMappings.find(roleMapping => roleMapping.user === userId);
      const newRole = this.roles.find(role => role.id === newRoleId);

      HTTP.patch(`roles/${currentRoleMapping.id}`, { role: newRoleId }).then(() => {
        this.roleMappings = this.roleMappings.map((roleMapping) => {
          if (roleMapping.id === currentRoleMapping.id) {
            return {
              ...currentRoleMapping,
              role: newRole.id,
              rolename: newRole.name,
            };
          }
          return roleMapping;
        });
      });
    },

    getOtherRoles(currentRoleID) {
      return this.roles.filter(role => role.id !== currentRoleID);
    },

    getOtherUsers() {
      const currentUserIds = new Set(this.roleMappings.map(roleMapping => roleMapping.user));
      return this.allUsers.filter(user => !currentUserIds.has(user.id));
    },
  },
};
</script>
