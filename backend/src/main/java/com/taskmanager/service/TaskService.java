package com.taskmanager.service;

import com.taskmanager.dto.TaskRequest;
import com.taskmanager.dto.TaskResponse;
import com.taskmanager.exception.ApiException;
import com.taskmanager.model.TaskModel;
import com.taskmanager.enumeration.TaskStatus;
import com.taskmanager.model.UserModel;
import com.taskmanager.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;

    public List<TaskResponse> getTasks(UserModel user, TaskStatus status, String search) {
        List<TaskModel> tasks;

        boolean hasStatus = status != null;
        boolean hasSearch = search != null && !search.isBlank();

        if (hasStatus && hasSearch) {
            tasks = taskRepository.findByUserAndStatusAndTitleContainingIgnoreCaseOrderByCreatedAtDesc(user, status, search);
        } else if (hasStatus) {
            tasks = taskRepository.findByUserAndStatusOrderByCreatedAtDesc(user, status);
        } else if (hasSearch) {
            tasks = taskRepository.findByUserAndTitleContainingIgnoreCaseOrderByCreatedAtDesc(user, search);
        } else {
            tasks = taskRepository.findByUserOrderByCreatedAtDesc(user);
        }

        return tasks.stream().map(TaskResponse::fromEntity).toList();
    }

    public TaskResponse createTask(UserModel user, TaskRequest request) {
        TaskModel task = TaskModel.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .status(request.getStatus() != null ? request.getStatus() : TaskStatus.TODO)
                .user(user)
                .build();

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    public TaskResponse updateTask(UserModel user, Long taskId, TaskRequest request) {
        TaskModel task = getOwnedTask(user, taskId);

        task.setTitle(request.getTitle());
        task.setDescription(request.getDescription());
        if (request.getStatus() != null) {
            task.setStatus(request.getStatus());
        }

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    public void deleteTask(UserModel user, Long taskId) {
        TaskModel task = getOwnedTask(user, taskId);
        taskRepository.delete(task);
    }

    private TaskModel getOwnedTask(UserModel user, Long taskId) {
        TaskModel task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ApiException("Tâche introuvable", HttpStatus.NOT_FOUND));

        if (!task.getUser().getId().equals(user.getId())) {
            throw new ApiException("Accès refusé à cette tâche", HttpStatus.FORBIDDEN);
        }

        return task;
    }
}
