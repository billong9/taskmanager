package com.taskmanager.repository;

import com.taskmanager.model.TaskModel;
import com.taskmanager.enumeration.TaskStatus;
import com.taskmanager.model.UserModel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TaskRepository extends JpaRepository<TaskModel, Long> {

    List<TaskModel> findByUserOrderByCreatedAtDesc(UserModel user);

    List<TaskModel> findByUserAndStatusOrderByCreatedAtDesc(UserModel user, TaskStatus status);

    List<TaskModel> findByUserAndTitleContainingIgnoreCaseOrderByCreatedAtDesc(UserModel user, String title);

    List<TaskModel> findByUserAndStatusAndTitleContainingIgnoreCaseOrderByCreatedAtDesc(
            UserModel user, TaskStatus status, String title);
}
