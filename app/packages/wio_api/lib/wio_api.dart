// Generated code - do not modify by hand
// ignore_for_file: lines_longer_than_80_chars


/// wio-app API
/// Version 1.0.0
/// API of wio-app, the field app for tidy-up and moving work. The phone writes locally first and syncs later; the server is the only place that orders changes (KB sync.md). Errors are application/problem+json with a machine `code` (D-98).
///
/// License: AGPL-3.0-only
/// License URL: https://www.gnu.org/licenses/agpl-3.0.html


library;

export 'src/api_client/auth_api.dart';
export 'src/api_client/files_api.dart';
export 'src/api_client/sync_api.dart';
export 'src/api_client/system_api.dart';
export 'src/model/accept_ranges_model.dart';
export 'src/model/change.dart';
export 'src/model/change_op_model.dart';
export 'src/model/change_result.dart';
export 'src/model/change_result_status_model.dart';
export 'src/model/conflict.dart';
export 'src/model/conflict_entity_model.dart';
export 'src/model/customer.dart';
export 'src/model/device.dart';
export 'src/model/device_list.dart';
export 'src/model/entity_label.dart';
export 'src/model/entity_label_entity_type_model.dart';
export 'src/model/entity_name.dart';
export 'src/model/entity_property.dart';
export 'src/model/entity_property_entity_type_model.dart';
export 'src/model/entry.dart';
export 'src/model/expense.dart';
export 'src/model/file_state.dart';
export 'src/model/fixture.dart';
export 'src/model/fixture_level.dart';
export 'src/model/fixture_levels.dart';
export 'src/model/fixture_levels_all_of_model.dart';
export 'src/model/health.dart';
export 'src/model/health_status_model.dart';
export 'src/model/job.dart';
export 'src/model/label.dart';
export 'src/model/me.dart';
export 'src/model/me_user.dart';
export 'src/model/me_user_role_model.dart';
export 'src/model/me_workspace.dart';
export 'src/model/me_workspace_plan_model.dart';
export 'src/model/note.dart';
export 'src/model/note_subject_type_model.dart';
export 'src/model/note_transcript_source_model.dart';
export 'src/model/opening.dart';
export 'src/model/opening_kind_model.dart';
export 'src/model/outline_point.dart';
export 'src/model/picture.dart';
export 'src/model/place_history.dart';
export 'src/model/problem.dart';
export 'src/model/property_key.dart';
export 'src/model/pull_result.dart';
export 'src/model/pulled_record.dart';
export 'src/model/push_request.dart';
export 'src/model/push_result.dart';
export 'src/model/room.dart';
export 'src/model/room_outline.dart';
export 'src/model/room_outline_all_of_model.dart';
export 'src/model/sign_in_request.dart';
export 'src/model/sign_in_result.dart';
export 'src/model/sign_off.dart';
export 'src/model/site.dart';
export 'src/model/time_block.dart';
export 'src/model/user.dart';
export 'src/model/user_role_model.dart';
export 'src/model/workspace.dart';
export 'src/model/workspace_plan_model.dart';
export 'src/model/workspace_ref.dart';
export 'src/response/auth_devices_device_id_delete503_response.dart';
export 'src/response/auth_devices_get503_response.dart';
export 'src/response/auth_me_get503_response.dart';
export 'src/response/auth_sign_in_post429_response.dart';
export 'src/response/auth_sign_in_post503_response.dart';
export 'src/response/auth_sign_out_post503_response.dart';
export 'src/response/files_sha256_get200_response.dart';
export 'src/response/files_sha256_get206_response.dart';
export 'src/response/files_sha256_get304_response.dart';
export 'src/response/files_sha256_get503_response.dart';
export 'src/response/files_sha256_put503_response.dart';
export 'src/response/files_sha256_state_get503_response.dart';
export 'src/response/maintenance.dart';
export 'src/response/sync_pull_get503_response.dart';
export 'src/response/sync_push_post503_response.dart';
export 'src/response/too_many_requests.dart';
export 'src/response_wrapper/get_file_response.dart';
export 'src/response_wrapper/get_file_state_response.dart';
export 'src/response_wrapper/get_health_response.dart';
export 'src/response_wrapper/get_me_response.dart';
export 'src/response_wrapper/list_devices_response.dart';
export 'src/response_wrapper/put_file_chunk_response.dart';
export 'src/response_wrapper/revoke_device_response.dart';
export 'src/response_wrapper/sign_in_response.dart';
export 'src/response_wrapper/sign_out_response.dart';
export 'src/response_wrapper/sync_pull_response.dart';
export 'src/response_wrapper/sync_push_response.dart';
export 'src/server/server.dart';
