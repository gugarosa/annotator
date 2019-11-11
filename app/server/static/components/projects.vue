<template lang="pug">
  div(v-cloak="")
    section.hero.project-image
      div.container
        div.columns
          div.column.is-10.is-offset-1

            h1.title.is-1.has-text-white Olá, {{ username | title }}.
            h2.subtitle.is-4.has-text-white Espero que hoje esteja sendo um ótimo dia de anotações!

            p(v-if="isSuperuser")
              a.button.is-medium.is-dark(v-on:click="isActive = !isActive")
                span.icon 
                  span.fas.fa-plus-square
                span Novo Projeto

    div.modal(v-bind:class="{ 'is-active': isActive }")
      div.modal-background
      div.modal-card
        header.modal-card-head
          p.modal-card-title Novo Projeto
          button.delete(aria-label="close", v-on:click="isActive = !isActive")

        section.modal-card-body
          div.field
            label.label Nome do Projeto
            div.control
              input.input(v-model="projectName", type="text", required, placeholder="Nome do Projeto")
            p.help.is-danger {{ projectNameError }}

          div.field
            label.label Descrição
            div.control
              textarea.textarea(v-model="description", required, placeholder="Descrição do Projeto")
            p.help.is-danger {{ descriptionError }}

          div.field
            label.label Tipo do Projeto

            div.control
              select(v-model="projectType", name="project_type", required)
                option(value="", selected="selected") ---------
                option(value="DocumentClassification") Classificação de Documentos
                option(value="SequenceLabeling") Reconhecimento de Entidades Nomeadas
                option(value="Seq2seq") Sequência para Sequência
            p.help.is-danger {{ projectTypeError }}

          div.field
            label.checkbox
              input(
                v-model="randomizeDocumentOrder"
                name="randomize_document_order"
                type="checkbox"
                style="margin-right: 0.25em;"
                required
              )
              | Utilizar ordem aleatória de documentos por usuário

          div.field
            label.checkbox
              input(
                v-model="collaborativeAnnotation"
                name="collaborative_annotation"
                type="checkbox"
                style="margin-right: 0.25em;"
                required
              )
              | Dividir anotações com todos os usuários

        footer.modal-card-foot.pt20.pb20.pr20.pl20.has-background-white-ter
          button.button.is-dark(v-on:click="create()")
            span.icon 
              span.fas.fa-check
            span Confirmar
          button.button(v-on:click="isActive = !isActive")
            span.icon 
              span.fas.fa-times
            span Cancelar

    div.modal(v-bind:class="{ 'is-active': isDelete }")
      div.modal-background
      div.modal-card
        header.modal-card-head
          p.modal-card-title Remover Projeto
          button.delete(aria-label="close", v-on:click="isDelete = !isDelete")
        section.modal-card-body Você tem certeza que deseja remover o projeto 
          b(v-if="project") {{ project.name }}
          span ?
        footer.modal-card-foot.pt20.pb20.pr20.pl20.has-background-white-ter
          button.button.is-danger(v-on:click="deleteProject()")
            span.icon 
              span.fas.fa-trash-alt
            span Remover
          button.button(v-on:click="isDelete = !isDelete")
            span.icon 
              span.fas.fa-times
            span Cancelar

    section.hero
      div.container
        div.columns
          div.column.is-10.is-offset-1
            div.card.events-card.pb10
              header.card-header
                p.card-header-title {{ items.length }} Projetos

                div.field.card-header-icon
                  div.control
                    div.select
                      select(v-model="selected")
                        option(selected) Todos os Projetos
                        option Classificação de Documentos
                        option Reconhecimento de Entidades Nomeadas
                        option Sequência para Sequência

              div.card-table
                div.content
                  table.table.is-fullwidth.is-hoverable
                    tbody
                      tr(v-for="project in selectedProjects", v-bind:key="project.id")
                        td.pl15r.pt20.pb20
                          div.thumbnail-wrapper.is-vertical
                            img.project-thumbnail(
                              v-bind:src="project.image"
                              alt="Project thumbnail"
                            )

                          div.dataset-item__main.is-vertical
                            div.dataset-item__main-title
                              div.dataset-item__main-title-link.dataset-item__link
                                a.has-text-black(v-bind:href="'/projects/' + project.id")
                                  | {{ project.name }}

                            div.dataset-item__main-subtitle {{ project.description }}
                            div.dataset-item__main-info
                              span.dataset-item__main-update atualizado há
                                span  {{ project.updated_at | daysAgo }}

                        td.is-vertical
                          span.tag.is-grey.is-medium {{ mapProject(project.project_type) }}

                        td.is-vertical(v-if="isProjectAdmin.get(project.id)")
                          a.button.is-dark.is-outlined(v-bind:href="'/projects/' + project.id + '/docs'")
                            span.icon 
                              span.fas.fa-pencil-alt
                            span Anotar

                        td.is-vertical(v-if="isProjectAdmin.get(project.id)")
                          a.button.is-danger.is-outlined(v-on:click="setProject(project)")
                            span.icon 
                              span.fas.fa-trash-alt
                            span Remover
</template>

<script>
import { title, daysAgo } from './filter';
import { defaultHttpClient } from './http';

export default {
  filters: { title, daysAgo },

  data: () => ({
    items: [],
    isActive: false,
    isDelete: false,
    project: null,
    selected: 'Todos os Projetos',
    projectName: '',
    description: '',
    projectType: '',
    descriptionError: '',
    projectTypeError: '',
    projectNameError: '',
    username: '',
    isSuperuser: false,
    randomizeDocumentOrder: false,
    collaborativeAnnotation: false,
    isProjectAdmin: null,
  }),

  computed: {
    selectedProjects() {
      return this.items.filter(item => this.selected === 'Todos os Projetos' || this.matchType(item.project_type));
    },
  },

  created() {
    Promise.all([
      defaultHttpClient.get('/v1/projects'),
      defaultHttpClient.get('/v1/me'),
    ]).then(([projects, me]) => {
      this.items = projects.data;
      this.username = me.data.username;
      this.isSuperuser = me.data.is_superuser;
      this.isProjectAdmin = new Map(this.items.map((project) => {
        const isProjectAdmin = project.current_users_role.is_project_admin;
        return [project.id, isProjectAdmin];
      }));
    });
  },

  methods: {
    deleteProject() {
      defaultHttpClient.delete(`/v1/projects/${this.project.id}`).then(() => {
        this.isDelete = false;
        const index = this.items.indexOf(this.project);
        this.items.splice(index, 1);
      });
    },

    setProject(project) {
      this.project = project;
      this.isDelete = true;
    },

    matchType(projectType) {
      if (projectType === 'DocumentClassification') {
        return this.selected === 'Classificação de Documentos';
      }
      if (projectType === 'SequenceLabeling') {
        return this.selected === 'Reconhecimento de Entidades Nomeadas';
      }
      if (projectType === 'Seq2seq') {
        return this.selected === 'Sequência para Sequência';
      }
      return false;
    },

    mapProject(projectType) {
      if (projectType === 'DocumentClassification') {
        return 'Classificação de Documentos';
      }
      if (projectType === 'SequenceLabeling') {
        return 'Reconhecimento de Entidades Nomeadas';
      }
      if (projectType === 'Seq2seq') {
        return 'Sequência para Sequência';
      }
    },

    create() {
      const payload = {
        name: this.projectName,
        description: this.description,
        project_type: this.projectType,
        randomize_document_order: this.randomizeDocumentOrder,
        collaborative_annotation: this.collaborativeAnnotation,
        guideline: 'Por favor, escreva o guia das regras de anotações.',
        resourcetype: this.resourceType(),
      };
      defaultHttpClient.post('/v1/projects', payload)
        .then((response) => {
          window.location = `/projects/${response.data.id}/docs/create`;
        })
        .catch((error) => {
          this.projectTypeError = '';
          this.projectNameError = '';
          this.descriptionError = '';
          if ('resourcetype' in error.response.data) {
            this.projectTypeError = error.response.data.resourcetype;
          }
          if ('name' in error.response.data) {
            this.projectNameError = error.response.data.name[0];
          }
          if ('description' in error.response.data) {
            this.descriptionError = error.response.data.description[0];
          }
        });
    },

    resourceType() {
      if (this.projectType === 'DocumentClassification') {
        return 'TextClassificationProject';
      }
      if (this.projectType === 'SequenceLabeling') {
        return 'SequenceLabelingProject';
      }
      if (this.projectType === 'Seq2seq') {
        return 'Seq2seqProject';
      }
      return '';
    },
  },
};
</script>
