<template>
  <v-container fluid>
    <v-data-iterator
      :items="items"
      item-key="name"
      :single-expand="true"
      hide-default-footer
    >
      <template 
        v-slot:header
        v-if="parentPath.length!=0 && isparent">
        <v-toolbar
          class="mb-2"
          color="indigo"
          dark
          flat
        >
          <v-toolbar-title>{{parentPath}}</v-toolbar-title>
        </v-toolbar>
      </template>
      <template v-slot:default="{ items, isExpanded, expand }">
        <v-container>
          <v-layout column justify-space-around>
            <v-flex lg12|md12
              v-for="item in items"
              :key="item.pk">
              <v-card
                :ripple="false"
                @click="(v) => expand(item, v)">
                <v-card-title>
                  <v-icon>mdi-folder</v-icon>
                  <h4>{{ item.name }}</h4>
                  <v-spacer/>
                  <v-dialog v-model="dialog4" persistent max-width="500">
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn
                        color="indigo"
                        dark
                        v-bind="attrs"
                        v-on="on"
                        @click="new_dir_path=parentPath"
                      >
                        Move
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="headline">어디로 옮기시겠습니까?</v-card-title>
                      <v-card-text>
                        <v-row justify="center">
                          <v-text-field
                            v-model="new_dir_path"
                            :disabled="lock"
                          ></v-text-field>
                        </v-row>
                        <v-col justify="center" align="center">
                          <v-progress-circular indeterminate color="indigo" v-if="loading4"/>
                          <div v-if="msg.length!=0">
                            <h3>{{msg}}</h3>
                          </div>
                        </v-col>
                      </v-card-text>
                      <v-card-actions v-if="!btn">
                        <v-spacer></v-spacer>
                        <v-btn color="indigo" 
                          text :disabled="loading4" 
                          @click="dialog4 = false; msg=''">옮기지 않을래요</v-btn>
                        <v-btn 
                          color="indigo" 
                          text :disabled="new_dir_path.length==0 || loading4" 
                          @click="moveDir(item.pk,new_dir_path); new_dir_path=''"
                        >
                          여기로 옮길게요
                        </v-btn>
                      </v-card-actions>
                      <v-card-actions v-else>
                        <v-spacer></v-spacer>
                        <v-btn 
                          color="indigo" 
                          text 
                          @click="dialog4 = false; btn = false; msg=''; lock = false; dirPath=''"
                        >
                          돌아가기
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                  <v-dialog v-model="dialog5" persistent max-width="500">
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn
                        color="indigo"
                        dark
                        v-bind="attrs"
                        v-on="on"
                      >
                        DELETE
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="headline">정말 지우시겠습니까?</v-card-title>
                      <v-card-text>
                        <v-col justify="center" align="center">
                          <v-progress-circular indeterminate color="indigo" v-if="loading5"/>
                          <div v-if="msg.length!=0">
                            <h3>{{msg}}</h3>
                          </div>
                        </v-col>
                      </v-card-text>
                      <v-card-actions v-if="!btn">
                        <v-spacer></v-spacer>
                        <v-btn color="indigo" 
                          text :disabled="loading5"
                          @click="dialog5 = false; 
                          msg=''">아니요</v-btn>
                        <v-btn color="indigo" text :disabled="loading5" @click="deleteDir(item.pk)">네</v-btn>
                      </v-card-actions>
                      <v-card-actions v-else>
                        <v-spacer></v-spacer>
                        <v-btn 
                          color="indigo" 
                          text 
                          @click="dialog5 = false; btn = false; msg=''"
                        >
                          돌아가기
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </v-card-title>
                <v-divider></v-divider>
                <v-list v-if="isExpanded(item)" dense>
                  <v-list-item v-if="item.children.length!=0">
                    <DirectoryRoot 
                      v-bind:items="item.children" 
                      v-bind:parentPath="parentPath"
                      :isparent="false"
                    />
                  </v-list-item>
                  <v-list-item
                    v-for="file in item.files"
                    :key="file.pk">
                    <v-icon>mdi-description</v-icon>
                    <h4>{{ file.name }}</h4>
                    <v-spacer/>
                    <v-dialog v-model="dialog2" persistent max-width="500">
                      <template v-slot:activator="{ on, attrs }">
                        <v-btn
                          color="indigo"
                          dark
                          v-bind="attrs"
                          v-on="on"
                          @click="new_dir_path=parentPath"
                        >
                          Move
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title class="headline">어디로 옮기시겠습니까?</v-card-title>
                        <v-card-text>
                          <v-row justify="center">
                            <v-text-field
                              v-model="new_dir_path"
                              :disabled="lock"
                            ></v-text-field>
                          </v-row>
                          <v-col justify="center" align="center">
                            <v-progress-circular indeterminate color="indigo" v-if="loading2"/>
                            <div v-if="msg.length!=0">
                              <h3>{{msg}}</h3>
                            </div>
                          </v-col>
                        </v-card-text>
                        <v-card-actions v-if="!btn">
                          <v-spacer></v-spacer>
                          <v-btn color="indigo" text :disabled="loading2" @click="dialog2 = false; msg=''">옮기지 않을래요</v-btn>
                          <v-btn 
                            color="indigo" 
                            text :disabled="new_dir_path.length==0 || loading2" 
                            @click="moveFile(file.pk,new_dir_path); new_dir_path=''"
                          >
                            여기로 옮길게요
                          </v-btn>
                        </v-card-actions>
                        <v-card-actions v-else>
                          <v-spacer></v-spacer>
                          <v-btn 
                            color="indigo" 
                            text 
                            @click="dialog2 = false; btn = false; msg=''; lock = false; new_dir_path=''"
                          >
                            돌아가기
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                    <v-dialog v-model="dialog3" persistent max-width="500">
                      <template v-slot:activator="{ on, attrs }">
                        <v-btn
                          color="indigo"
                          dark
                          v-bind="attrs"
                          v-on="on"
                        >
                          DELETE
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title class="headline">정말 지우시겠습니까?</v-card-title>
                        <v-card-text>
                          <v-col justify="center" align="center">
                            <v-progress-circular indeterminate color="indigo" v-if="loading3"/>
                            <div v-if="msg.length!=0">
                              <h3>{{msg}}</h3>
                            </div>
                          </v-col>
                        </v-card-text>
                        <v-card-actions v-if="!btn">
                          <v-spacer></v-spacer>
                          <v-btn color="indigo" text :disabled="loading3" @click="dialog3 = false; msg=''">아니요</v-btn>
                          <v-btn color="indigo" text :disabled="loading3" @click="deleteFile(file.pk)">네</v-btn>
                        </v-card-actions>
                        <v-card-actions v-else>
                          <v-spacer></v-spacer>
                          <v-btn 
                            color="indigo" 
                            text 
                            @click="dialog3 = false; btn = false; msg=''"
                          >
                            돌아가기
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-list-item>
                </v-list>
              </v-card>
            </v-flex>
          </v-layout>
        </v-container>
      </template>
    </v-data-iterator>
  </v-container>
</template>


<script>
  import {mapMutations} from 'vuex'
  export default {
    name: 'DirectoryRoot',
    components: {
      DirectoryRoot: Object
    },
    props: {
      parentPath: String,
      isparent: Boolean,
      items: Array
    },
    data: () => ({
      dialog2: false,
      dialog3: false,
      dialog4: false,
      dialog5: false,
      loading2: false,
      loading3: false,
      loading4: false,
      loading5: false,
      btn: false,
      msg: "",
      lock: false,
      new_dir_path: "",
    }),
    methods: { 
      ...mapMutations('fetch',[
        'switchOn'
      ]),
      moveDir(pk,new_dir_path) {
        var that = this;
        that.loading4 = true;
        that.lock = true;
        return new Promise((resolve, reject) => {
          try {
            this.$http
              .get(`/api/dirs/${pk}/move?new_dir_path=${new_dir_path}`)
              .then(res => {
                if (res.data.status!='ok') {
                  setTimeout(() => {
                    that.loading4 = false;
                    that.lock = false;
                    this.msg = "파일 옮기기에 실패했습니다, 올바른 디렉토리 경로가 아닙니다";
                    this.new_dir_path = this.parentPath;
                  }, 2000);
                  throw "move file error";
                }
              })
              .then(() => {
                setTimeout(() => {
                  that.loading4 = false;
                  that.btn = true;
                  this.msg = "성공적으로 파일을 옮겼습니다";
                  this.switchOn();
                }, 2000);
              });
          } catch (error) {
            reject(error);
          }
        });
      },
      deleteDir(pk) {
        var that = this;
        that.loading5 = true;
        return new Promise((resolve, reject) => {
          try {
            this.$http
              .delete(`/api/dirs/${pk}/`)
              .then(res => {
                if (res.data.status=='no') {
                  setTimeout(() => {
                    that.loading5 = false;
                    this.msg = "파일 삭제에 실패했습니다. 관리자에게 문의하십시오.";
                  }, 2000);
                  throw "delete directory error";
                }
              })
              .then(() => {
                setTimeout(() => {
                  that.loading5 = false;
                  that.btn = true;
                  this.msg = "성공적으로 파일을 삭제했습니다";
                  this.switchOn();
                }, 2000);
              });
          } catch (error) {
            reject(error);
          }
        });
      },
      moveFile(pk,new_dir_path) {
        var that = this;
        that.loading2 = true;
        that.lock = true;
        return new Promise((resolve, reject) => {
          try {
            this.$http
              .get(`/api/files/${pk}/move?new_dir_path=${new_dir_path}`)
              .then(res => {
                if (res.data.status!='ok') {
                  setTimeout(() => {
                    that.loading2 = false;
                    that.lock = false;
                    this.msg = "파일 옮기기에 실패했습니다, 올바른 디렉토리 경로가 아닙니다";
                    this.new_dir_path = this.parentPath;
                  }, 2000);
                  throw "move file error";
                }
              })
              .then(() => {
                setTimeout(() => {
                  that.loading2 = false;
                  that.btn = true;
                  this.msg = "성공적으로 파일을 옮겼습니다";
                  this.switchOn();
                }, 2000);
              });
          } catch (error) {
            reject(error);
          }
        });
      },
      deleteFile(pk) {
        var that = this;
        that.loading3 = true;
        return new Promise((resolve, reject) => {
          try {
            this.$http
              .delete(`/api/files/${pk}/`)
              .then(res => {
                if (res.data.status=='no') {
                  setTimeout(() => {
                    that.loading3 = false;
                    this.msg = "파일 삭제에 실패했습니다. 관리자에게 문의하십시오.";
                  }, 2000);
                  throw "delete directory error";
                }
              })
              .then(() => {
                setTimeout(() => {
                  that.loading3 = false;
                  that.btn = true;
                  this.msg = "성공적으로 파일을 삭제했습니다";
                  this.switchOn();
                }, 2000);
              });
          } catch (error) {
            reject(error);
          }
        });
      }
    }
  }
</script>