##########################################################################
# Copyright 2016 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class JettyWeakEtagMiddleware
  def initialize(app)
    @app = app
  end

  MATCH_REGEX = /--(gzip|deflate)"$/
  REPLACE_REGEX = /--(gzip|deflate)"?$/

  def call(env)
    # make weak etags sent by jetty strong see: http://stackoverflow.com/questions/18693718/weak-etags-in-rails
    if env['HTTP_IF_MATCH'] =~ MATCH_REGEX
      env['HTTP_IF_MATCH'] = env['HTTP_IF_MATCH'].gsub(REPLACE_REGEX, '"')
    end

    if env['HTTP_IF_NONE_MATCH'] =~ MATCH_REGEX
      env['HTTP_IF_NONE_MATCH'] = env['HTTP_IF_NONE_MATCH'].gsub(REPLACE_REGEX, '"')
    end

    status, headers, body = @app.call(env)
    [status, headers, body]
  end
end
