module AresMUSH
  module Pose_History
    
    # When a pose is sent through, it triggers this method. 
    # update_history takes the following:
    # room -> Key value for hash
    # name -> Key value for nested hash
    # time -> Nested hash value
    # pose -> Nested hash value
    def self.update_history(room, name, time, pose)
      if (pose_history.nil?)
        Pose_History.initiate_history(room, name, time, pose)
        
      else
        Pose_History.add_pose(room, name, time, pose)
        
      end
    end
  end
end


